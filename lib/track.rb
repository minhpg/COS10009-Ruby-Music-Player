class Track

    attr_accessor :name, :path, :dimension

    def initialize(
        name = nil,
        path = nil,
        dimension = nil
    )
        @name = name
        @path = path
        @dimension = dimension
    end

end
