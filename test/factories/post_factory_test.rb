require 'test_helper'

class PostFactoryTest < ActiveSupport::TestCase
  test 'create_post should return nil if given a nil value for post_contents' do 
    # Act
    result = PostFactory.create_post(nil)

    # Assert
    assert_nil result
  end

  test 'create_post should return nil if given a non-string type for post_contents' do
    # Act
    result = PostFactory.create_post(1)

    # Assert
    assert_nil result
  end

  test 'create_post should return a post model with correct values' do 
    # Arrange
    post_contents = %(---
layout: post
title: Some Post
author: Andrew Wojciechowski
tags:
  - announcement
  - info
hero: https://source.unsplash.com/collection/145103/
overlay: green
---
#An H1 tag
##An H2 tag)

    # Act
    result = PostFactory.create_post(post_contents)

    # Assert
    assert_equal 'Some Post', result.title
    assert_equal 'Andrew Wojciechowski', result.author
    assert_equal 'announcement, info', result.tags
    assert_equal 'https://source.unsplash.com/collection/145103/', result.hero
    assert_equal 'green', result.overlay
    assert_equal "#An H1 tag\n##An H2 tag", result.contents
  end
end
