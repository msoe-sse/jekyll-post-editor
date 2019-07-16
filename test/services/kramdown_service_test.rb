require 'test_helper'

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
end
