require 'test_helper'
require 'mocha/setup'

class KramdownServiceTest < ActiveSupport::TestCase
  LEAD_BREAK_SECTION = "{: .lead}\r\n<!–-break-–>"

  test 'get_preview should convert markdown to html' do
    # Arrange
    markdown = %(#Andy is cool
Andy is nice)

    # Act
    result = KramdownService.get_preview(markdown)

    # Assert
    assert_not_nil result
  end
  
  test 'get_preview should not update the src atribute of image tags if no uploader exists in PostImageManager' do 
    # Arrange
    mock_uploader = MockUploader.new
    mock_uploader.filename = 'no image.png'
    mock_uploader.cache_name = 'my cache'

    PostImageManager.instance.expects(:uploaders).returns([ mock_uploader ])

    markdown = '![20170610130401_1.jpg](/assets/img/20170610130401_1.jpg)'

    # Act
    result = KramdownService.get_preview(markdown)

    # Assert
    assert_equal "<p><img src=\"/assets/img/20170610130401_1.jpg\" alt=\"20170610130401_1.jpg\" /></p>\n", result
  end

  test 'get_preview should update the src attribute of image tags if an uploader exists in PostImageManager' do 
    # Arrange
    mock_uploader = MockUploader.new
    mock_uploader.filename = '20170610130401_1.jpg'
    mock_uploader.cache_name = 'my cache/20170610130401_1.jpg'

    PostImageManager.instance.expects(:uploaders).returns([ mock_uploader ])

    markdown = '![My Alt Text](/assets/img/20170610130401_1.jpg)'

    # Act
    result = KramdownService.get_preview(markdown)

    # Assert
    assert_equal "<p><img src=\"/uploads/tmp/my cache/20170610130401_1.jpg\" alt=\"My Alt Text\" /></p>\n", result
  end

  test 'create_jekyll_post_text should return text for a formatted post' do 
    # Arrange
    expected_post = %(---
layout: post
title: Some Post
author: Andy Wojciechowski\r
hero: https://source.unsplash.com/collection/145103/
overlay: green
published: true
---
#{LEAD_BREAK_SECTION}
# An H1 tag\r
##An H2 tag)

    # Act
    result = KramdownService.create_jekyll_post_text("#An H1 tag\r\n##An H2 tag", 'Andy Wojciechowski', 
                                                     'Some Post', '', 'Green')

    # Assert
    assert_equal expected_post, result
  end

  test 'create_jekyll_post_text should return a formatted post given valid post tags' do 
    # Arrange
    expected_post = %(---
layout: post
title: Some Post
author: Andy Wojciechowski\r
tags:
  - announcement\r
  - info\r
hero: https://source.unsplash.com/collection/145103/
overlay: green
published: true
---
#{LEAD_BREAK_SECTION}
# An H1 tag\r
##An H2 tag)
    # Act
    result = KramdownService.create_jekyll_post_text("#An H1 tag\r\n##An H2 tag",
                                                     'Andy Wojciechowski', 'Some Post', 'announcement, info', 'green')
    # Assert
    assert_equal expected_post, result
  end

  test 'create_jekyll_post_text should add a space after the # symbols indicating a header tag' do 
    # Arrange
    expected_post = %(---
layout: post
title: Some Post
author: Andy Wojciechowski\r
hero: https://source.unsplash.com/collection/145103/
overlay: green
published: true
---
#{LEAD_BREAK_SECTION}
# H1 header\r
\r
## H2 header\r
\r
### H3 header\r
\r
#### H4 header\r
\r
##### H5 header\r
\r
###### H6 header)

    markdown_text = %(#H1 header\r
\r
##H2 header\r
\r
###H3 header\r
\r
####H4 header\r
\r
#####H5 header\r
\r
######H6 header)

    # Act
    result = KramdownService.create_jekyll_post_text(markdown_text, 'Andy Wojciechowski', 'Some Post', '', 'Green')

    # Assert
    assert_equal expected_post, result
  end

  test 'create_jekyll_post_text should only add one space after a header' do 
    # Arrange
    expected_post = %(---
layout: post
title: Some Post
author: Andy Wojciechowski\r
tags:
  - announcement\r
  - info\r
hero: https://source.unsplash.com/collection/145103/
overlay: green
published: true
---
#{LEAD_BREAK_SECTION}
# An H1 tag\r
##An H2 tag)
    # Act
    result = KramdownService.create_jekyll_post_text("# An H1 tag\r\n##An H2 tag",
                                                     'Andy Wojciechowski', 'Some Post', 'announcement, info', 'green')
    # Assert
    assert_equal expected_post, result
  end

  private
    class MockUploader
      attr_accessor :filename
      attr_accessor :cache_name
    end
end
