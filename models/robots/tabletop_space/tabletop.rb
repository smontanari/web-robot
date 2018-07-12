require_relative 'position'

module Robots
  module TabletopSpace
    class Tabletop
      class PositionNotAvailable < StandardError; end

      class GridCell
        attr_reader :position

        def initialize(x, y)
          @position = Position.new(x, y)
        end

        def take(robot)
          raise PositionNotAvailable.new 'Position already taken' if @robot != nil
          @robot = robot
        end

        def release
          @robot = nil
        end

        def has?(robot)
          @robot == robot
        end
      end

      class SquareGrid
        def initialize(dimension)
          @cells = []
          @table_range = (1..dimension)
          @table_range.each do |y|
            @cells << [].tap do |row|
              @table_range.each {|x| row << GridCell.new(x, y)}
            end
          end
          @flat_cells_array = @cells.flatten
        end

        def cell_at(*coordinates)
          x, y = coordinates
          raise PositionNotAvailable.new 'Position outside table boundary' unless @table_range.cover? x and @table_range.cover? y
          @cells[y-1][x-1]
        end

        def where_is?(robot)
          @flat_cells_array.find { |c| c.has? robot }
        end
      end

      def initialize dimension
        @semaphore = Mutex.new
        @grid = SquareGrid.new(dimension)
      end

      def move_to robot, *coordinates
        @semaphore.synchronize do
          destination_cell = @grid.cell_at(*coordinates)
          origin_cell = @grid.where_is?(robot)
          destination_cell.take(robot)
          origin_cell.release if origin_cell
          destination_cell.position
        end
      end

      def remove(robot)
        @semaphore.synchronize do
          cell = @grid.where_is?(robot)
          cell.release if cell
        end
      end
    end
  end
end
