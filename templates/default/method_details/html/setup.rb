def init
  super
  
  # Added the annotated source template to the end of the sections to be rendered.
  sections.push(:annotated_source)
  
  # object contains the method details that are about to be processed. 
  # 
  # object.source contains all the source within the method that we can use
  # to generate the inline documentation. We should allow for the normal sour
  # 
  # Source with annotations would simply look at the source and each line with 
  # a comment would be lumped together with comments.
  object.annotated_source = annotate_source(object.source)
  
end

#
# The comments within a method are just strings and have not been converted into
# Docstrings. Here we hijack the method object and send it to the docstring
# template to be rendered with the new docstring.
# 
# @param [String] comments that should be converted into a docstring and then
#   rendered with the docstring template.
# @return [String] the rendered results of the docstring
def docstring_comment(comments)
  method_object = object.dup
  object.docstring = Docstring.new(comments,object)
  
  result = T('docstring').run(options)
  object = method_object
  result
end

#
# This method will find the comments and then the source code (non-comments) and
# generate an array of comment-code pairs which should be displayed next to each
# other.
# 
# @param [String] source that will be scanned and annotated
# 
# @return [Array<Array<String,String>>] an array of arrays. Each element contains
#   in the first element the comments, the second contains the source code.
def annotate_source(source)
  
  annotated = []
  current_comment = nil
  current_code = nil
  finished_comment = nil
  
  # Move through the source code line by line.
  # When we come to a comment line (starts with #) then we add a source
  # When we come to a non-comment line we are done builing that comment
  #   we would then start to build the source up line by line
  source.split("\n").each do |line|
    
    if line =~ /^\s*#.*$/
      
      # When parsing a comment
      # 
      # If we are parsing the first comment then we need to look to see if there
      # was some code that we were parsing and finish that code. Then we need to
      # add the comment to a new array of comments
      # 
      # If this is another comment, after the first one then we need to add it
      # to the list of comments.
      if current_comment
        current_comment << line[/^\s*#\s?(.+)/,1].to_s
      else
        
        if current_code
          annotated << [ finished_comment, current_code ]
          finished_comment = current_code = nil
          
        end
      
        (current_comment ||=[]) << line[/^\s*#\s?(.+)/,1].to_s
      end
      
    else

      # When parsing a line of code
      # 
      # If we are parsing the first line of code then if there are any comments
      # then we are done with the comments that are associated with this line of
      # code (and any lines that follow). We want to save the finished block of
      # comments so that we can put it together with the code when we are finished
      # with it.
      # 
      if current_comment
        finished_comment = current_comment
        current_comment = nil
      else
        # We were not working on a comment
      end
      
      # Add the current code line to the current_code if one exists (create one if it does not exist)
      (current_code ||= []) << line.to_s
      
    end
    
  end
  
  # If we have finished parsing lines and we still have code within a home, which
  # is likely if the the source code ends with an end. We want to create a new pair
  if current_code
    annotated << [ finished_comment, current_code ]
    current_code = nil
  end
  
  # If we have a comment that still remains, then the comment exists without
  # source and we should add it the pairs.
  if current_comment
    annotated << [ current_comment, "" ]
    current_comment = nil
  end
  
  return annotated
end

def show_annotated_lines(section)
  @current_count ||= object.line
  
  # Add the comment line length to the line number
  @current_count += Array(section.first).length
  
  lines = (@current_count..(@current_count+Array(section.last).length)).to_a.join("\n")
  @current_count += Array(section.last).length
  lines
end
