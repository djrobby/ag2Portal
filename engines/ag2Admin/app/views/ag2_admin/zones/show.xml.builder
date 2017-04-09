xml.instruct!
xml.zone do
	xml.name           @zone.name
	xml.organization   @zone.organization.name
	xml.offices do
		@zone.offices.each do |office|
			xml.office do
        xml.code   office.office_code
        xml.name   office.name
      end
		end
	end
end
