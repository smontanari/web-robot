require 'spec_helper'

module Robots
  module TabletopSpace
    describe Tabletop do
      let(:subject) { Tabletop.new 3 }
      let(:robot_1) { Object.new }
      let(:robot_2) { Object.new }

      it 'returns a position within the table' do
        expect(subject.move_to(robot_1, 1, 2)).to be_a_tabletop_position.with_x(1).with_y(2)
      end

      it 'raises an error if trying to access a position outside the table' do
        expect {subject.move_to(robot_1, 1, 4)}.to raise_error Tabletop::PositionNotAvailable
      end

      it 'raises an error if trying to access a position already taken' do
        subject.move_to(robot_2, 2, 3)
        expect {subject.move_to(robot_1, 2, 3)}.to raise_error Tabletop::PositionNotAvailable
      end

      it 'takes a new position releasing the previous one' do
        subject.move_to(robot_1, 2, 3)
        subject.move_to(robot_1, 1, 1)
        subject.move_to(robot_2, 2, 3)
      end

      it 'releases a taken position' do
        subject.move_to(robot_1, 2, 3)
        subject.remove(robot_1)
        subject.move_to(robot_2, 2, 3)
      end
    end
  end
end
