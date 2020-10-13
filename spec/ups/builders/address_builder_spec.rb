require "spec_helper"

describe UPS::Builders::AddressBuilder do
  describe "when passed a US Address" do
    let(:address_hash) { {
      address_line_1: 'Googleplex',
      address_line_2: '1600 Amphitheatre Parkway',
      city: 'Mountain View',
      state: 'California',
      postal_code: '94043',
      country: 'US',
    } }

    describe "with a non-abbreviated state" do
      subject { UPS::Builders::AddressBuilder.new address_hash }

      it "should change the state to be the abbreviated state name" do
        subject.opts[:state].must_equal 'CA'
      end
    end

    describe "with a non-abbreviated state with mixed casing" do
      subject { UPS::Builders::AddressBuilder.new address_hash.merge({ state: 'CaLiFoRnIa' }) }

      it "should change the state to be the abbreviated state name" do
        subject.opts[:state].must_equal 'CA'
      end
    end

    describe "with an abbreviated state" do
      subject { UPS::Builders::AddressBuilder.new address_hash.merge({ state: 'ca' }) }

      it "should retrun the abbreviated state" do
        subject.opts[:state].must_equal 'CA'
      end
    end
  end

  describe "when passed a Canadian Address" do
    let(:address_hash) { {
      address_line_1: '1253 McGill College',
      city: 'Montreal',
      state: 'Quebec',
      postal_code: 'H3B 2Y5',
      country: 'CA',
    } }

    describe "with a non-abbreviated state" do
      subject { UPS::Builders::AddressBuilder.new address_hash }

      it "should change the state to be the abbreviated state name" do
        subject.opts[:state].must_equal 'QC'
      end
    end

    describe "with a non-abbreviated state with mixed casing" do
      subject { UPS::Builders::AddressBuilder.new address_hash.merge({ state: 'QuEbEc' }) }

      it "should change the state to be the abbreviated state name" do
        subject.opts[:state].must_equal 'QC'
      end
    end

    describe "with an abbreviated state" do
      subject { UPS::Builders::AddressBuilder.new address_hash.merge({ state: 'qc' }) }

      it "should retrun the abbreviated state" do
        subject.opts[:state].must_equal 'QC'
      end
    end
  end

  describe "when passed a IE address" do
    let(:address_hash) { {
      address_line_1: 'Barrow Street',
      city: 'Dublin 4',
      state: 'County Dublin',
      postal_code: '',
      country: 'IE',
    } }

    describe "normalizes the state field" do
      subject { UPS::Builders::AddressBuilder.new address_hash }

      it "should change the state to be the abbreviated state name" do
        subject.opts[:state].must_equal 'Dublin'
      end
    end

    describe "when passed a empty state" do
      subject { UPS::Builders::AddressBuilder.new address_hash.merge({ state: '' }) }
      it "should throw an exception" do
        proc { subject }.must_raise UPS::Exceptions::InvalidAttributeError
      end
    end

    describe "when 'skip_ireland_state_validation' is passed" do
      before { address_hash.merge!(skip_ireland_state_validation: true) }

      describe "does not normalize the state field" do
        subject { UPS::Builders::AddressBuilder.new address_hash }

        it "changes the state to a single blank character" do
          subject.opts[:state].must_equal '_'
        end
      end

      describe "when passed a empty state" do
        subject { UPS::Builders::AddressBuilder.new address_hash.merge({ state: '' }) }

        it "does not throw an exception" do
          subject.opts[:state].must_equal '_'
        end
      end
    end
  end

  describe 'residential address' do
    it 'is not a residential address by default' do
      address = UPS::Builders::AddressBuilder.new(address_line_1: 'Googleplex', city: 'Mountain View', state: 'California', postal_code: '94043', country: 'US')

      expect(address.to_xml.locate('ResidentialAddressIndicator')).must_equal([])
    end

    it 'is indicates when specified as a residential address' do
      address = UPS::Builders::AddressBuilder.new(address_line_1: 'Googleplex', city: 'Mountain View', state: 'California', postal_code: '94043', country: 'US', residential_address: true)

      expect(address.to_xml.locate('ResidentialAddressIndicator')).wont_equal([])
    end
  end

  it 'treats address_line_1 as optional' do
    organisation = UPS::Builders::AddressBuilder.new(city: 'Mountain View', state: 'California', postal_code: '94043', country: 'US')

    expect(organisation.to_xml.locate('AddressLine1')).must_equal([])
  end

  it 'treats city as optional' do
    organisation = UPS::Builders::AddressBuilder.new(address_line_1: 'Googleplex', state: 'California', postal_code: '94043', country: 'US')

    expect(organisation.to_xml.locate('City')).must_equal([])
  end
end
