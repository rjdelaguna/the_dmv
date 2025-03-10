require 'spec_helper'

RSpec.describe Facility do
  before(:each) do
    @facility = Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600'})
  end
  describe '#initialize' do
    it 'can initialize' do

      expect(@facility).to be_an_instance_of(Facility)
      expect(@facility.name).to eq('DMV Tremont Branch')
      expect(@facility.address).to eq('2855 Tremont Place Suite 118 Denver CO 80205')
      expect(@facility.phone).to eq('(720) 865-4600')
      expect(@facility.services).to eq([])
    end
  end

  describe '#add service' do
    it 'can add available services' do

      expect(@facility.services).to eq([])
      @facility.add_service('New Drivers License')
      @facility.add_service('Renew Drivers License')
      @facility.add_service('Vehicle Registration')
      expect(@facility.services).to eq(['New Drivers License', 'Renew Drivers License', 'Vehicle Registration'])
    end
  end

  describe '#register_vehicle' do
    before(:each) do
      @facility_1 = Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600'})
      @facility_2 = Facility.new({name: 'DMV Northeast Branch', address: '4685 Peoria Street Suite 101 Denver CO 80239', phone: '(720) 865-4600'})
      @cruz = Vehicle.new({vin: '123456789abcdefgh', year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice} )
      @bolt = Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev} )
      @camaro = Vehicle.new({vin: '1a2b3c4d5e6f', year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice} )
      @facility_1.add_service('Vehicle Registration')
    end

    it 'shows vehicles registration, facility registered vehicles, and collected fees have no values to begin' do
      
      expect(@cruz.registration_date).to eq(nil)
      expect(@facility_1.registered_vehicles).to eq([])
      expect(@facility_1.collected_fees).to eq(0)
    end

    it 'updates vehicle with registration information' do
      @facility_1.register_vehicle(@cruz)

      expect(@cruz.registration_date).to eq(Date.today)
      expect(@cruz.plate_type).to eq(:regular)
    end

    it 'updates registered vehicles and collected fees for the facility the vehicle was registered to' do
      @facility_1.register_vehicle(@cruz)

      expect(@facility_1.registered_vehicles).to eq([@cruz])
      expect(@facility_1.collected_fees).to eq(100)
    end

    it 'makes changes based on the called object' do
      @facility_1.register_vehicle(@cruz)
      @facility_1.register_vehicle(@camaro)
      @facility_1.register_vehicle(@bolt)

      expect(@camaro.registration_date).to eq(Date.today)
      expect(@camaro.plate_type).to eq(:antique)
      expect(@bolt.registration_date).to eq(Date.today)
      expect(@bolt.plate_type).to eq(:ev)
      expect(@facility_1.registered_vehicles).to eq([@cruz, @camaro, @bolt])
      expect(@facility_1.collected_fees).to eq(325)
    end

    it 'will not perform services the facility does not offer' do

      expect(@facility_2.registered_vehicles).to eq([])
      expect(@facility_2.services).to eq([])

      @facility_2.register_vehicle(@bolt)

      expect(@facility_2.registered_vehicles).to eq([])
      expect(@facility_2.collected_fees).to eq(0)
    end
  end

  describe 'all methods related to getting a drivers license' do
    before(:each) do
      @registrant_1 = Registrant.new('Bruce', 18, true )
      @registrant_2 = Registrant.new('Penny', 16 )
      @registrant_3 = Registrant.new('Tucker', 15 )
      @facility_1 = Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600'})
      @facility_2 = Facility.new({name: 'DMV Northeast Branch', address: '4685 Peoria Street Suite 101 Denver CO 80239', phone: '(720) 865-4600'})
    end

    describe '#written test' do
      it 'will administer test if the facility does not offer the service' do 

        expect(@registrant_1.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
        expect(@registrant_1.permit?).to eq(true)
        expect(@facility_1.services).to eq([])

        @facility_1.administer_written_test(@registrant_1)

        expect(@registrant_1.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
      end

      it 'administers written tests if the service is offered' do
        @facility_1.add_service('Written Test')
        @facility_1.administer_written_test(@registrant_1)

        expect(@registrant_1.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
      end

      it 'will not administer a written test if the registant has not yet earned their permit' do
        @facility_1.add_service('Written Test')

        expect(@registrant_2.age).to eq(16)
        expect(@registrant_2.permit?).to eq(false)

        @facility_1.administer_written_test(@registrant_2)
        
        expect(@registrant_2.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
        
        @registrant_2.earn_permit
        @facility_1.administer_written_test(@registrant_2)
        
        expect(@registrant_2.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
      end

      it 'will not administer a written test if the registrant is under 16 years old' do
        @facility_1.add_service('Written Test')
        @registrant_3.earn_permit

        expect(@registrant_3.age).to eq(15)
        expect(@registrant_3.permit?).to eq(true)
        expect(@registrant_3.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
        
        @facility_1.administer_written_test(@registrant_3)
        
        expect(@registrant_3.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
      end
    end

    describe '#road test' do
      it 'administers road tests only if the service is offered' do
        @facility_1.add_service('Written Test')
        @facility_1.administer_written_test(@registrant_1)

        expect(@registrant_1.license_data).to eq({:written=>true, :license=>false, :renewed=>false})

        @facility_1.administer_road_test(@registrant_1)
        
        expect(@registrant_1.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
      end

      it 'administers road test only if written test has been passed' do
        @facility_1.add_service('Written Test')
        @facility_1.add_service('Road Test')
        
        expect(@facility_1.services).to eq(["Written Test", "Road Test"])
        
        @registrant_2.earn_permit
        @facility_1.administer_written_test(@registrant_2)
        
        expect(@registrant_2.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
        
        @facility_1.administer_road_test(@registrant_2)
        
        expect(@registrant_2.license_data).to eq({:written=>true, :license=>true, :renewed=>false})
        
        @facility_1.administer_road_test(@registrant_1)
        
        expect(@registrant_1.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
        
        @registrant_3.earn_permit
        @facility_1.administer_written_test(@registrant_3)
        @facility_1.administer_road_test(@registrant_3)
        
        expect(@registrant_3.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
      end
    end

    describe '#renew license' do
      it 'only renews licenses if facility offers the service' do
        @facility_1.add_service('Written Test')
        @facility_1.add_service('Road Test')
        @facility_1.administer_written_test(@registrant_1)
        @facility_1.administer_road_test(@registrant_1)
        @facility_1.renew_drivers_license(@registrant_1)
        
        expect(@facility_1.services).to eq(["Written Test", "Road Test"])
        expect(@registrant_1.license_data).to eq({:written=>true, :license=>true, :renewed=>false})
        
        @facility_1.add_service('Renew License')
        @facility_1.renew_drivers_license(@registrant_1)
        
        expect(@facility_1.services).to eq(["Written Test", "Road Test", "Renew License"])
        expect(@registrant_1.license_data).to eq({:written=>true, :license=>true, :renewed=>true})
      end

      it 'only renews license if registrant already has a license' do
        @facility_1.add_service('Written Test')
        @facility_1.add_service('Road Test')
        @facility_1.add_service('Renew License')
        @facility_1.administer_written_test(@registrant_1)
        @facility_1.renew_drivers_license(@registrant_1)
        
        expect(@registrant_1.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
      end
    end
  end
end
