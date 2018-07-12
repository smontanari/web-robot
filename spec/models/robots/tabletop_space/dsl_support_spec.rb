require 'spec_helper'

module Robots
  module TabletopSpace
    describe DSLSupport do
      let(:subject) do
        robot_class = Class.new do
          include DSLSupport
        end
        robot_class.new
      end

      it 'provides methods to translate facing parameters to Facing objects' do
        expect(subject.north).to eq Facing::North
        expect(subject.east).to eq Facing::East
        expect(subject.south).to eq Facing::South
        expect(subject.west).to eq Facing::West
      end

      [:right, :left, :move].each do |action|
        it "provides the #{action} action" do
          expect(subject.find_movement_action(action)).to eq action.to_s
        end
      end

      it "does not find a 'test' action" do
        expect(subject.find_movement_action(:test)).to be_nil
      end
    end
  end
end
