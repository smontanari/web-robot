require 'spec_helper'

module Robots
  describe Robot do
    subject { Robot.new('test_id', 'test_name') }

    context 'actions' do
      before(:each) do
        allow(subject).to receive(:find_movement_action).with(:test_movement).and_return :go_somwhere
      end

      it 'returns a robot status' do
        subject.current_position = double(to_h: 'test_position')
        subject.current_facing = 'test_facing'

        expect(subject.status).to eq({
          robot_id: 'test_id',
          name: 'test_name',
          position: 'test_position',
          facing: 'test_facing'
        })
      end

      it 'performs a movement' do
        subject.current_position = 'test_position'
        expect(subject).to receive(:action_go_somwhere)

        subject.test_movement
      end

      it "raises an error when attempting a movement action if not placed in a valid position" do
        expect { subject.test_movement }.to raise_error 'Robot not placed on the map'
      end
    end

    it 'moves on a tabletop' do
      expect(Robot.include? TabletopSpace).to be_truthy
    end

    it 'enables dsl' do
      expect(Robot.include? CommandDSLEnabled).to be_truthy
    end
  end
end
