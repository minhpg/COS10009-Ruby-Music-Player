require_relative('album')
require_relative('track')
require_relative('input_functions')
require 'gosu'

def loadAlbums(path)
    fileObject = File.new(path, "r")
    count = fileObject.gets.chomp.to_i
    
    albums = []
    while count > 0
        album = readAlbum(fileObject)
        albums << album
        count -= 1
    end
    fileObject.close()
    return albums
end

# Read a single track
def readTrack(fileObject)
    track_name = fileObject.gets
    track_location = fileObject.gets
    track = Track.new(
        name = track_name,
        path = track_location,
        dimension = Dimension.new(
            0, 0, 0, 0
        )
    )
    return track
end
  
  # Read all tracks of an album
def readTracks(fileObject)
    count = fileObject.gets.chomp.to_i
    tracks = []

    while count > 0
        track = readTrack(fileObject)
        tracks.append(track)
        count -= 1
    end
    return tracks
end
  
  # Read a single album
def readAlbum(fileObject)
    title = fileObject.gets.delete("\n")
    artist = fileObject.gets.delete("\n")
    image_path = fileObject.gets.delete("\n")
    # genre = fileObject.gets.to_i
    tracks = readTracks(fileObject)
    album = Album.new(
        artist = artist,
        name = title,
        year = nil,
        genres = [],
        tracks = tracks,
        artwork = Gosu::Image.new(image_path),
        dimension = Dimension.new(
            0, 0, 0, 0
        )
    )
    return album
end
