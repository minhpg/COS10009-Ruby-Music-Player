class Album

    attr_accessor :artist, :name, :year, :genres, :tracks, :artwork, :dimension

    def initialize(
        artist = nil,
        name = nil,
        year = nil,
        genres = [],
        tracks = [],
        artwork = nil,
        dimension = nil
    )
        @artist = artist
        @name = name
        @year = year
        @genres = genres
        @tracks = tracks
        @artwork = artwork
        @dimension = dimension
    end

end
