require 'csv'

module FarMar
  class Vendor
    attr_reader :vendor_id, :name, :employees, :market_id
    attr_accessor
    attr_writer

    def initialize(vendor_hash)
      @vendor_id = vendor_hash["vendor_id"]
      @name = vendor_hash["name"]
      @employees = vendor_hash["employees"]
      @market_id = vendor_hash["market_id"]
      @sales_by_vendor = []
    end

    # Reads CSV file to generate array of vendor hashes
    def self.all
      vendors = []
      CSV.read("./support/vendors.csv").each do |line|
        vendor_hash = {}
        vendor_hash["vendor_id"] = line[0].to_i
        vendor_hash["name"] = line[1]
        vendor_hash["employees"] = line[2].to_i
        vendor_hash["market_id"] = line[3].to_i
        vendors << FarMar::Vendor.new(vendor_hash)
      end
      return vendors
    end

    # Iterates through all vendors to find and print information about
    # vendors with a specified vendor_id
    def self.find(input)
      vendors = self.all
      vendors.each do |var|
        if var.vendor_id == input
          puts var.print_props
          return var
        end
      end
    end

    # Instance method to print properties of vendors
    def print_props
      return "Vendor ID #{ @vendor_id }, named #{ @name }, has #{ @employees } employees #{ @amount } and is sold at Market ID #{ @market_id }."
    end

    # Class method that generates an array of vendors with a
    # specified market_id
    def self.by_market(input)
      vendor_by_market = []
      vendors = self.all
      vendors.each do |var|
        if var.market_id == input
          vendor_by_market << var
        end
      end
      return vendor_by_market
    end

    # Instance method that looks through both markets and vendors to find
    # those with matching market_id, to figure out at what market a particular
    # vendor is located.
    def market
      markets = FarMar::Market.all
      markets.each do |var|
        if var.market_id == @market_id # Need one instance of market_id (don't technically need @ sign, but I like it there)
          return var
        end
      end
    end

    # Instance method that returns an array of Products that
    # have a particular vendor_id
    def products
      return FarMar::Product.by_vendor(vendor_id)
    end

    # Instance method that generates all Sales and iterates through them to
    # create an array of sales according to a certain vendor_id
    def sales
      sales = FarMar::Sale.all
      sales.each do |var|
        if var.vendor_id == @vendor_id
          @sales_by_vendor << var
        end
      end
      return @sales_by_vendor
    end

    # Instance method that uses sales to generate an array, then goes through
    # that array to calculate the revenue from the sales by that vendor
    def revenue
      sales
      revenue = 0
      @sales_by_vendor.each do |i|
        revenue += i.amount
      end
      return revenue
    end

    # Class method that returns the top vendor instances ranked by total revenue
    # I strongly suspect there is a much more elegant way to do this, but I ran
    # out of time. I also only managed to return the top value, rather than the
    # top n values.
    def self.most_revenue
      sales = FarMar::Sale.all
      top_vendors = {}
      # Create a hash with the vendor_id as a key and an array as the value,
      # using sale.amount as each item of the array
      sales.each do |sale|
        unless top_vendors.has_key?(sale.vendor_id)
          top_vendors.merge!(sale.vendor_id => [sale.amount])
        # Push the amount into the value array
        else
          top_vendors[sale.vendor_id] << sale.amount
        end
      end
      # This creates an array of arrays, with [0] in each one equal to vendor_id
      # and [1] in each equal to the summed sale.amounts.
      top_reduced = top_vendors.map do |key, val|
        [key, val.reduce(:+)]
      end
      maximum = 0
      vendor_id = nil
      top_reduced.each do |i|
        if i[1] > maximum
          maximum = i[1]
          vendor_id = i[0]
        end
      end
      puts "Vendor ID #{ vendor_id } had the most revenue of #{ maximum } cents."
      return maximum
    end
  end
end
