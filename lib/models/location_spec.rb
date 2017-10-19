require './location.rb'

#location_spec.rb
RSpec.describe Location do
  descibe '#load_all' do
    it 'returns an object of location from a spesific name' do
      locs = Location.load_all
      expect(locs[0].name).to eq('blok m')
      expect(locs[1].name).to eq('kemang')
      expect(locs[0].coord).to contain_exactly(15, 35)
    end
  end  
end
