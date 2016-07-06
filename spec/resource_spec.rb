require 'spec_helper'

describe Resource do

  class Resource
    class Foo < self
      METADATA = {
        a: [:key, :create, :something],
        b: [:create, :another_thing],
        c: [:something],
        d: [:something, :another_thing]
      }
    end
  end

  describe '#create' do
    context 'Config file has all :key values' do
      it 'Does not throw an error' do
        expect { 
          begin
            Resource::Foo.new(a: 'key', b: 'foo', c: 'bar').create 
          rescue Resource::Unimplemented
          end
        }.not_to raise_error
      end
    end

    context 'Config file is missing a :key value' do
      it 'Throws an error' do
        expect { Resource::Foo.new(b: 'foo', c: 'bar').create }.to raise_error Resource::MissingProperties
      end
    end
  end

  describe '#modify' do
    context 'Config file is missing a :key value' do
      it 'Throws an error' do
        expect { Resource::Foo.new(b: 'foo', c: 'bar').modify }.to raise_error Resource::MissingProperties
      end
    end
  end
end
