require 'spec_helper'

module Robots
  module TabletopSpace
    describe Facing do
      facings = [Facing::North, Facing::East, Facing::South, Facing::West]
      facings.each_with_index do |facing, idx|
        expected_facing = {right: facings.rotate(idx + 1).first, left: facings[idx - 1]}
        describe facing do
          [:right, :left].each do |rotation|
            it "returns #{expected_facing[rotation]} when rotating #{rotation}" do
              expect(facing.send("rotate_#{rotation}".to_sym)).to eq expected_facing[rotation]
            end
          end
        end
      end
    end
  end
end
