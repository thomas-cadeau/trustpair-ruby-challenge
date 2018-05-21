require_relative '../../lib/trustpair/opendata/opendata_api'
require_relative '../../lib/trustpair/challenge_runner'

RSpec.describe 'Trustpair::ChallengeRunner' do

  describe '.run' do
    context 'with a CSV input file path'
    before {
      api = Trustpair::Opendata::OpendataApi.new()
      allow(api).to receive(:searchBySirets)
                        .with(['8329406800001', '34313476300048'])
                        .and_return([{'record' => {
                            'fields' => {
                                'l1_normalisee' => 'VIVENDI',
                                'siret' => '34313476300048',
                                'apen700' => '7010Z',
                                'libnj' => 'SA à directoire (s.a.i.)',
                                'dcren' => '1987-10-30',
                                'numvoie' => '42',
                                'typvoie' => 'AV',
                                'libvoie' => 'DE FRIEDLAND',
                                'codpos' => '75008',
                                'libcom' => 'PARIS 8'
                            }
                        }}])
      @challenge = Trustpair::ChallengeRunner.new(api)
    }
    it 'should call the opendatasoftware API and fill the ouput with data from the record' do
      result = @challenge.run(File.dirname(__FILE__) + '/../../test/data/data.csv')
      expect(result).to eq([{:company_name => "VIVENDI",
                             :siret => "34313476300048",
                             :ape => "7010Z",
                             :legal_nature => "SA à directoire (s.a.i.)",
                             :creation_date => "1987-10-30",
                             :address => "42 AV DE FRIEDLAND 75008 PARIS 8"}])
    end
  end

end

