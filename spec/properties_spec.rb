require 'spec_helper'

describe Resource::Properties do

  class Foo
    METADATA = {
      age: [],
      name: [:key, :create],
      stuff: [:create],
      type: []
    }
  end


  config = {
    name: 'the_name',
    size: '24',
    status: 'running'
  }

  prop = Resource::Properties.new(Foo, config)

  describe ".valid?" do

    context "when :key is passed and all keys flagged with :key are present" do
      it "returns true" do
        expect(prop.valid?(:key)).to be true
      end
    end

    context "when :create is passed and one or more keys flagged with :create are missing" do
      it "returns false" do
        expect(prop.valid?(:create)).to be false
      end
    end

    context "when and unkown symbol is given" do
      it "returns true" do
        expect(prop.valid?(:bar)).to be true
      end
    end
  end
end
