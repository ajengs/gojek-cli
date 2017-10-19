require_relative './location.rb'

#location_spec.rb
RSpec.describe Location do
  describe '#load_all' do
    it 'returns an array of objects of location' do
      locs = Location.load_all
      expect(locs[0].name).to eq('blok m')
      expect(locs[1].name).to eq('kemang')
      expect(locs[0].coord).to contain_exactly(15, 35)
    end
  end  
  describe '#find' do
    it 'returns an object of location from name' do
      ori = Location.find('kemang')
      expect(ori.name).to eq('kemang')
    end
  end
end
