require 'spec_helper'

RSpec.describe WebRobot::RobotControl do
  let(:app) { double(call: nil) }
  let(:logger) { double(info: nil) }
  let(:robots_store) { double }

  subject { described_class.new(app, logger) }

  context 'handling a standard http request' do
    it 'forwards the request to the application' do
      allow(Faye::WebSocket).to receive(:websocket?).with('env').and_return(false)
      expect(app).to receive(:call).with('env')

      subject.call('env')
    end
  end

  context 'handling a websocket request' do
    let(:websocket) { double(send: nil, object_id: nil) }
    let(:event) { double(data:'"test-event"') }

    before do
      allow(WebRobot::RobotsStore).to receive(:new).and_return(robots_store)
      allow(Faye::WebSocket).to receive(:websocket?).with('env').and_return(true)
      allow(Faye::WebSocket).to receive(:new).and_return(websocket)
      allow(websocket).to receive(:on).with(:open)
      allow(websocket).to receive(:on).with(:message)
      allow(websocket).to receive(:on).with(:close)
      allow(websocket).to receive(:rack_response).and_return('rack-response')
      allow(robots_store).to receive(:process).with('test-event').and_return(['msg_response', 'broadcast_msg'])
    end

    it 'return the rack response' do
      expect(subject.call('env')).to eq('rack-response')
    end

    it 'stores the websocket in memory' do
      allow(websocket).to receive(:on).with(:open).and_yield(event)
      subject.call('env')

      expect(subject.instance_variable_get(:@ws_clients)).to include(websocket)
    end

    it 'responds to a websocket message' do
      allow(websocket).to receive(:on).with(:message).and_yield(event)

      expect(websocket).to receive(:send).with('"msg_response"')
      subject.call('env')
    end

    it 'broadcasts a message to all websockets' do
      ws1, ws2 = [double, double]
      subject.instance_variable_set(:@ws_clients, [ws1, ws2])
      allow(websocket).to receive(:on).with(:message).and_yield(event)

      expect(ws1).to receive(:send).with('"broadcast_msg"')
      expect(ws2).to receive(:send).with('"broadcast_msg"')
      subject.call('env')
    end

    it 'removes the websocket from memory' do
      allow(websocket).to receive(:on).with(:close).and_yield(double(code: nil, reason: nil))
      expect(subject.instance_variable_get(:@ws_clients)).to_not include(websocket)

      subject.call('env')
    end
  end
end
