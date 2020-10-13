require "spec_helper"

describe UPS::Builders::OrganisationBuilder do
  subject { UPS::Builders::OrganisationBuilder.new(builder_name) }

  describe "when the name is 'SoldTo'" do
    let(:builder_name) { 'SoldTo' }

    it "enables option to skip Ireland state validation" do
      subject.opts[:skip_ireland_state_validation].must_equal true
    end
  end

  describe "when the name is anything else" do
    let(:builder_name) { 'Hamburger' }

    it "disables option to skip Ireland state validation" do
      subject.opts[:skip_ireland_state_validation].must_equal false
    end
  end

  it 'treats company_name as optional' do
    organisation = UPS::Builders::OrganisationBuilder.new('ShipTo', phone_number: '867-5309', attention_name: 'Rick', address_line_1: 'Googleplex', city: 'Mountain View', state: 'California', postal_code: '94043', country: 'US')

    expect(organisation.to_xml.locate('CompanyName')).must_equal([])
  end

  it 'treats phone_number as optional' do
    organisation = UPS::Builders::OrganisationBuilder.new('ShipTo', company_name: 'Google Inc.', attention_name: 'Rick', address_line_1: 'Googleplex', city: 'Mountain View', state: 'California', postal_code: '94043', country: 'US')

    expect(organisation.to_xml.locate('PhoneNumber')).must_equal([])
  end

  it 'treats attention_name as optional' do
    organisation = UPS::Builders::OrganisationBuilder.new('ShipTo', company_name: 'Google Inc.', phone_number: '867-5309', address_line_1: 'Googleplex', city: 'Mountain View', state: 'California', postal_code: '94043', country: 'US')

    expect(organisation.to_xml.locate('AttentionName')).must_equal([])
  end
end
