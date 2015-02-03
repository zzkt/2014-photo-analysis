# -*- mode: enh-ruby; coding: utf-8; -*-
#
# Image and metadata analysis for photoset 02014 (365)
#
# Copyright (C) 2014 FoAM vzw
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.
#
# Authors
#  - nik gaffney <nik@fo.am>
#
# Requirements
#  - flickraw
#
# Commentary
#  - Flickr docs and reference http://www.rubydoc.info/github/hanklords/flickraw
#
# Changes
# 2014-12-07
#  - mostly working port from racket

require 'flickraw'
require 'yaml'

CONFIG = YAML.load_file("config.yml")

FlickRaw.api_key = CONFIG['api_key']
FlickRaw.shared_secret = CONFIG['shared_secret']

flickr.access_token = CONFIG['access_token']
flickr.access_secret = CONFIG['access_secret']

#FlickRaw.check_certificate = false #assume no malevolence

# specifics

photoset_02014 = '72157639545946114'
zzkt =  {"id"=>"52731283@N06", "username"=>"zzkt"}

# {pre}authentication (via https://github.com/hanklords/flickraw)
  
login = flickr.test.login
puts "You are now authenticated as #{login.username}"

# photsets

def get_photoset (set_id)
   flickr.photosets.getPhotos(:photoset_id => set_id, :extras => 'views,tags,date_taken')
end 

def get_photo_list (set_id)
  h = flickr.photosets.getPhotos(:photoset_id => set_id, :extras => 'views,tags,date_taken').to_hash
  return h.assoc("photo")[1] # => array of hashes or flickr::responses
end

# sorted photolist of photo titles and views

def sort_by_views (photo_list)
  sorted = photo_list.sort_by { |photo| photo.views.to_i }
  return sorted
end

# extract various info re. favourites

def favourites (photo)
  favs = Array.new
  flickr.photos.getFavorites(photo_id: photo.id).to_hash.assoc('person')[1].map do
    |fav| favs << fav.username
  end
  return favs
end

# titles, contexts, views and favourites from a photoset. (e.g photo 15740214669)

def get_sets (photo)
  sets = Array.new
  response=flickr.photos.getAllContexts(photo_id: photo.id).to_hash.assoc('set')
  if (not response.nil?)
    response[1].map do
      |cx| sets << cx.title
    end
  end
  return sets
end

def get_groups (photo)
  groups = Array.new
  response=flickr.photos.getAllContexts(photo_id: photo.id).to_hash.assoc('pool')
  if (not response.nil?)
    response[1].map do
      |cx| groups << cx.title
    end
  end
  return groups
end

def titles_and_views (photo_list)
  photo_list.map do
    |photo|  puts "#{photo.title} views:#{photo.views}"
  end
end

# interestingness

def most_interesting (user_id)
  flickr.photos.search(:user_id => user_id,
                       :sort =>'interestingness-desc', 
                       :min_taken_date =>'2014-01-01 00:00:00',
                       :per_page => '500',
                       :extras => 'views')
end

# extract tags and tag counts

def photoset_tags(set_id)
  tag_count = Hash.new(0)
  flickr.photosets.getPhotos(photoset_id: set_id, extras: 'views,tags,date_taken').photo.map do
    |photo|  photo.tags.split(" ").each { |name| tag_count[name] += 1 }
  end
  return tag_count
end



### #  #  # ## ##    ###  # 
#
# output / testing
#
## #   ##  # ####  #  #


def exfoliate (set_id)
   flickr.photosets.getPhotos(photoset_id: set_id, extras: 'views,tags,date_taken').photo.map do
     |photo|
     # puts "title: #{photo.title} \nviews: #{photo.views}"
     # puts "favourited by: #{favourites(photo)}"
     # puts "in sets: #{get_sets(photo)}"
     # puts "in groups: #{get_groups(photo)}"
     # puts "/// /  /"
     
     puts "#{photo.title},#{photo.views},#{favourites(photo).length},#{get_sets(photo)}, #{get_groups(photo)},#{photo.tags}\n"

   end
   puts "tags by freq: #{photoset_tags(set_id)}"
end


def photoset_urls(set_id)
  flickr.photosets.getPhotos(photoset_id: set_id).photo.map do
      |photo|  FlickRaw.url_b(photo)
  end
end


exfoliate('72157639545946114') # 2014


#########  #   # #  #         #  
#
#  unported, testing and troubled.. .
#
####  #   #  # #     #
