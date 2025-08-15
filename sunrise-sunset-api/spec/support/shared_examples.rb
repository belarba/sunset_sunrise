RSpec.shared_examples 'successful sunrise sunset data' do
  it 'returns valid sunrise sunset data' do
    expect(subject).to be_an(Array)
    expect(subject).not_to be_empty

    record = subject.first
    expect(record).to be_a(SunriseSunsetData)
    expect(record.date).to be_present
    expect(record.location).to be_present
    expect(record.latitude).to be_a(Numeric)
    expect(record.longitude).to be_a(Numeric)
  end
end

RSpec.shared_examples 'polar region data' do
  it 'handles polar region correctly' do
    expect(subject).to be_an(Array)

    record = subject.first
    expect(record.sunrise).to be_nil if record.polar_night? || record.polar_day?
    expect(record.sunset).to be_nil if record.polar_night? || record.polar_day?
    expect([true, false]).to include(record.polar_day?)
    expect([true, false]).to include(record.polar_night?)
  end
end
