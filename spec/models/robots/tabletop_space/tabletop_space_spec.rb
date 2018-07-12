require 'spec_helper'

module Robots
  describe TabletopSpace do
    it 'provides support for the tabletop dsl' do
      expect(subject.include? TabletopSpace::DSLSupport).to be_truthy
    end

    it 'provides support for the tabletop movement' do
      expect(subject.include? TabletopSpace::Movement).to be_truthy
    end
  end
end
