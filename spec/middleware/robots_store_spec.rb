require 'spec_helper'

RSpec.describe WebRobot::RobotsStore do
  subject { described_class.new(4) }

  def create_robot_message(message_id, name)
    {
      'id' => message_id,
      'payload' => {
        'action' => 'create',
        'content' => { 'name' => name }
      }
    }
  end

  def place_robot_message(message_id, robot_id, place_args)
    {
      'id' => message_id,
      'payload' => {
        'action' => 'execute',
        'content' => {
          'robot_id' => robot_id,
          'command' => "place #{place_args}"
        }
      }
    }
  end

  def verify_successful_response(response, message_id, payload)
    expect(response[:id]).to eq(message_id)
    expect(response[:payload]).to eq(payload)
  end

  def verify_error_response(response, message_id, error_msg)
    expect(response[:id]).to eq(message_id)
    expect(response[:error]).to eq(error_msg)
  end

  describe 'processing messages' do
    it 'adds a robot' do
      allow(SecureRandom).to receive(:uuid).and_return('123');
      response = subject.process(create_robot_message('xyz', 'test_robot'))

      expect(response.length).to eq(1)
      verify_successful_response(response.first, 'xyz', { robot_id: '123' })
    end

    it 'attempts to add a robot until it finds a valid uuid' do
      allow(SecureRandom).to receive(:uuid).and_return('123', '123', '123', '456');
      subject.process(create_robot_message('xyz', 'test_robot1'))

      response = subject.process(create_robot_message('xyz', 'test_robot2'))

      expect(response.length).to eq(1)
      verify_successful_response(response.first, 'xyz', { robot_id: '456' })
    end

    it 'fails to add a robot after three attempts to find a valid uuid' do
      allow(SecureRandom).to receive(:uuid).and_return('123', '123', '123', '123');
      subject.process(create_robot_message('xyz', 'test_robot1'))

      response = subject.process(create_robot_message('xyz', 'test_robot2'))

      expect(response.length).to eq(1)
      verify_error_response(response.first, 'xyz', 'Could not generate unique robot id')
    end

    it 'places a robot' do
      allow(SecureRandom).to receive(:uuid).and_return('123');
      subject.process(create_robot_message('xyz', 'test_robot'))

      response = subject.process(place_robot_message('abc', '123', '2, 3, north'))

      expect(response.length).to eq(2)
      verify_successful_response(response[0], 'abc', nil)
      verify_successful_response(response[1], 'robot_status', {
        robot_id: '123',
        name: 'test_robot',
        position: { x: 2, y: 3 },
        facing: Robots::TabletopSpace::Facing::North
      })
    end

    it 'lists all the placed robots' do
      allow(SecureRandom).to receive(:uuid).and_return('123', '456', '789');
      subject.process(create_robot_message('xyz', 'test_robot1'))
      subject.process(create_robot_message('xyz', 'test_robot2'))
      subject.process(create_robot_message('xyz', 'test_robot3'))
      subject.process(place_robot_message('abc', '123', '2, 3, north'))
      subject.process(place_robot_message('abc', '789', '4, 1, east'))

      response = subject.process('id' => 'abc', 'payload' => { 'action' => 'list' })

      expect(response.length).to eq(1)
      verify_successful_response(response.first, 'abc', [
        {
          robot_id: '123',
          name: 'test_robot1',
          position: { x: 2, y: 3 },
          facing: Robots::TabletopSpace::Facing::North
        },
        {
          robot_id: '789',
          name: 'test_robot3',
          position: { x: 4, y: 1 },
          facing: Robots::TabletopSpace::Facing::East
        }
      ])
    end

    it 'removes a placed robot' do
      allow(SecureRandom).to receive(:uuid).and_return('123');
      subject.process(create_robot_message('xyz', 'test_robot'))
      subject.process(place_robot_message('abc', '123', '2, 3, north'))

      response = subject.process('id' => 'abc', 'payload' => {
        'action' => 'destroy',
        'content' => { 'robot_id' => '123' }
      })

      expect(response.length).to eq(2)
      verify_successful_response(response[0], 'abc', nil)
      verify_successful_response(response[1], 'robot_exit', { robot_id: '123' })
    end

    it 'removes a non placed robot' do
      allow(SecureRandom).to receive(:uuid).and_return('123');
      subject.process(create_robot_message('xyz', 'test_robot'))

      response = subject.process('id' => 'abc', 'payload' => {
        'action' => 'destroy',
        'content' => { 'robot_id' => '123' }
      })

      expect(response.length).to eq(1)
      verify_successful_response(response[0], 'abc', nil)
    end
  end
end
