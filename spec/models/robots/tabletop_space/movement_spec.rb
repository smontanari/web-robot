require 'spec_helper'

module Robots
  module TabletopSpace
    describe Movement do
      let(:tabletop) {double('tabletop')}
      let(:subject) do
        robot_class = Class.new do
          include Movement
          attr_accessor :current_position, :current_facing
        end
        robot_class.new.tap {|r| r.enter_space tabletop}
      end
      let(:test_position) {Position.new 'x', 'y'}

      it 'places itself on the table' do
        allow(tabletop).to receive(:move_to).with(subject, 1, 2).and_return test_position

        subject.place 1, 2, Facing::East

        expect(subject.current_position).to be_a_tabletop_position.with_x('x').with_y('y')
        expect(subject.current_facing).to be Facing::East
      end

      it 'cannot place two times' do
        allow(tabletop).to receive(:move_to).with(subject, 1, 2).and_return test_position
        subject.place 1, 2, Facing::East

        expect {subject.place 3, 1, Facing::North}.to raise_error(StandardError, 'Robot already in position')
      end

      {
        Facing::North => [1, 3],
        Facing::East  => [2, 2],
        Facing::South => [1, 1],
        Facing::West  => [0, 2]
      }.each do |facing, coordinates|
        it "moves #{facing} on the table by 1 step" do
          allow(tabletop).to receive(:move_to).with(subject, coordinates[0], coordinates[1]).and_return test_position

          subject.current_position = Position.new 1, 2
          subject.current_facing = facing
          subject.action_move

          expect(subject.current_position).to be_a_tabletop_position.with_x('x').with_y('y')
        end
      end

      it 'exits the space' do
        allow(tabletop).to receive(:move_to).with(subject, 1, 2).and_return test_position
        subject.place 1, 2, Facing::East

        expect(tabletop).to receive(:remove).with(subject)

        subject.exit_space

        expect(subject.current_position).to be_nil
        expect(subject.current_facing).to be_nil

        expect {subject.place 1, 2, Facing::East}.to raise_error(NoMethodError)
      end

      {
        Facing::North => [2, 5],
        Facing::East  => [4, 3],
        Facing::South => [2, 1],
        Facing::West  => [0, 3]
      }.each do |facing, coordinates|
        it "moves #{facing} on the table by 2 steps" do
          allow(tabletop).to receive(:move_to).with(subject, coordinates[0], coordinates[1]).and_return test_position

          subject.current_position = Position.new 2, 3
          subject.current_facing = facing
          subject.action_move 2

          expect(subject.current_position).to be_a_tabletop_position.with_x('x').with_y('y')
        end
      end

      it "rotates right" do
        subject.current_facing = Facing::North
        subject.action_right

        expect(subject.current_facing).to eq Facing::East
      end

      it "rotates left" do
        subject.current_facing = Facing::West
        subject.action_left

        expect(subject.current_facing).to be Facing::South
      end
    end
  end
end
