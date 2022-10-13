$GENRES = ['Rap', 'Pop', 'Classic', 'Jazz', 'Rock']

def getGenre(int)
    return $GENRES[int]
end

def fetchAllGenres()
    return $GENRES
end

def searchGenre(int, albums)
    valid_albums = []
    albums.map { |album| 
        if album.genres.include? int
            valid_albums.append(album)
            next
        end
    }
    return valid_albums
end

def getGenreString(genres)
    string = ''
    genres.each_with_index do |value, index|
        if (index == (genres.length - 1))
            line_end = ''
        else 
            line_end = ', '
        end
        string = string+getGenre(value-1)+line_end;
    end
    return string
end
