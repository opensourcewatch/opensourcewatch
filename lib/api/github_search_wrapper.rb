require 'uri'

class GithubSearchWrapper
  @BASE_URL = 'https://api.github.com/search/repositories'
  @access_token = ENV["GITHUB_API_KEY"]
  @repos_processed = 0
  # Github will only return 34 * 30 results
  REPOS_PROCESSED_PAGINATION_MAX = 1020
  @languages = [
    "ActionScript",
    "C",
    "C",
    "C++",
    "Clojure",
    "CoffeeScript",
    "CSS",
    "Go",
    "Haskell",
    "HTML",
    "Java",
    "JavaScript",
    "Lua",
    "Matlab",
    "Objective-C",
    "Perl",
    "PHP",
    "Python",
    "VimL",
    "R",
    "Ruby",
    "Scala",
    "Shell",
    "Swift",
    "TeX",
    "1C Enterprise",
    "ABAP",
    "ABNF",
    "Ada",
    "Agda",
    "AGS Script",
    "Alloy",
    "Alpine Abuild",
    "AMPL",
    "Ant Build System",
    "ANTLR",
    "ApacheConf",
    "Apex",
    "API Blueprint",
    "APL",
    "Apollo Guidance Computer",
    "AppleScript",
    "Arc",
    "Arduino",
    "AsciiDoc",
    "ASN.1",
    "ASP",
    "AspectJ",
    "Assembly",
    "ATS",
    "Augeas",
    "AutoHotkey",
    "AutoIt",
    "Awk",
    "Batchfile",
    "Befunge",
    "Bison",
    "BitBake",
    "Blade",
    "BlitzBasic",
    "BlitzMax",
    "Bluespec",
    "Boo",
    "Brainfuck",
    "Brightscript",
    "Bro",
    "C-ObjDump",
    "C2hs Haskell",
    "Cap'n Proto",
    "CartoCSS",
    "Ceylon",
    "Chapel",
    "Charity",
    "ChucK",
    "Cirru",
    "Clarion",
    "Clean",
    "Click",
    "CLIPS",
    "CMake",
    "COBOL",
    "ColdFusion",
    "ColdFusion CFC",
    "COLLADA",
    "Common Lisp",
    "Component Pascal",
    "Cool",
    "Coq",
    "Cpp-ObjDump",
    "Creole",
    "Crystal",
    "CSON",
    "Csound",
    "Csound Document",
    "Csound Score",
    "CSV",
    "Cucumber",
    "Cuda",
    "Cycript",
    "Cython",
    "D",
    "D-ObjDump",
    "Darcs Patch",
    "Dart",
    "desktop",
    "Diff",
    "DIGITAL Command Language",
    "DM",
    "DNS Zone",
    "Dockerfile",
    "Dogescript",
    "DTrace",
    "Dylan",
    "E",
    "Eagle",
    "EBNF",
    "eC",
    "Ecere Projects",
    "ECL",
    "ECLiPSe",
    "edn",
    "Eiffel",
    "EJS",
    "Elixir",
    "Elm",
    "Emacs Lisp",
    "EmberScript",
    "EQ",
    "Erlang",
    "F#",
    "Factor",
    "Fancy",
    "Fantom",
    "Filebench WML",
    "Filterscript",
    "fish",
    "FLUX",
    "Formatted",
    "Forth",
    "FORTRAN",
    "FreeMarker",
    "Frege",
    "G-code",
    "Game Maker Language",
    "GAMS",
    "GAP",
    "GAS",
    "GCC Machine Description",
    "GDB",
    "GDScript",
    "Genshi",
    "Gentoo Ebuild",
    "Gentoo Eclass",
    "Gettext Catalog",
    "GLSL",
    "Glyph",
    "GN",
    "Gnuplot",
    "Golo",
    "Gosu",
    "Grace",
    "Gradle",
    "Grammatical Framework",
    "Graph Modeling Language",
    "GraphQL",
    "Graphviz (DOT)",
    "Groff",
    "Groovy",
    "Groovy Server Pages",
    "Hack",
    "Haml",
    "Handlebars",
    "Harbour",
    "Haxe",
    "HCL",
    "HLSL",
    "HTML+Django",
    "HTML+ECR",
    "HTML+EEX",
    "HTML+ERB",
    "HTML+PHP",
    "HTTP",
    "Hy",
    "HyPhy",
    "IDL",
    "Idris",
    "IGOR Pro",
    "Inform 7",
    "INI",
    "Inno Setup",
    "Io",
    "Ioke",
    "IRC log",
    "Isabelle",
    "Isabelle ROOT",
    "J",
    "Jade",
    "Jasmin",
    "Java Server Pages",
    "JFlex",
    "JSON",
    "JSON5",
    "JSONiq",
    "JSONLD",
    "JSX",
    "Julia",
    "Jupyter Notebook",
    "KiCad",
    "Kit",
    "Kotlin",
    "KRL",
    "LabVIEW",
    "Lasso",
    "Latte",
    "Lean",
    "Less",
    "Lex",
    "LFE",
    "LilyPond",
    "Limbo",
    "Linker Script",
    "Linux Kernel Module",
    "Liquid",
    "Literate Agda",
    "Literate CoffeeScript",
    "Literate Haskell",
    "LiveScript",
    "LLVM",
    "Logos",
    "Logtalk",
    "LOLCODE",
    "LookML",
    "LoomScript",
    "LSL",
    "M",
    "M4",
    "M4Sugar",
    "Makefile",
    "Mako",
    "Markdown",
    "Mask",
    "Mathematica",
    "Maven POM",
    "Max",
    "MAXScript",
    "MediaWiki",
    "Mercury",
    "Metal",
    "MiniD",
    "Mirah",
    "Modelica",
    "Modula-2",
    "Module Management System",
    "Monkey",
    "Moocode",
    "MoonScript",
    "MQL4",
    "MQL5",
    "MTML",
    "MUF",
    "mupad",
    "Myghty",
    "NCL",
    "Nemerle",
    "nesC",
    "NetLinx",
    "NetLinx+ERB",
    "NetLogo",
    "NewLisp",
    "Nginx",
    "Nimrod",
    "Ninja",
    "Nit",
    "Nix",
    "NL",
    "NSIS",
    "Nu",
    "NumPy",
    "ObjDump",
    "Objective-C++",
    "Objective-J",
    "OCaml",
    "Omgrofl",
    "ooc",
    "Opa",
    "Opal",
    "OpenCL",
    "OpenEdge ABL",
    "OpenRC runscript",
    "OpenSCAD",
    "OpenType Feature File",
    "Org",
    "Ox",
    "Oxygene",
    "Oz",
    "Pan",
    "Papyrus",
    "Parrot",
    "Parrot Assembly",
    "Parrot Internal Representation",
    "Pascal",
    "PAWN",
    "Perl6",
    "Pic",
    "Pickle",
    "PicoLisp",
    "PigLatin",
    "Pike",
    "PLpgSQL",
    "PLSQL",
    "Pod",
    "PogoScript",
    "Pony",
    "PostScript",
    "POV-Ray SDL",
    "PowerBuilder",
    "PowerShell",
    "Processing",
    "Prolog",
    "Propeller Spin",
    "Protocol Buffer",
    "Public Key",
    "Puppet",
    "Pure Data",
    "PureBasic",
    "PureScript",
    "Python console",
    "Python traceback",
    "QMake",
    "QML",
    "Racket",
    "Ragel in Ruby Host",
    "RAML",
    "Rascal",
    "Raw token data",
    "RDoc",
    "REALbasic",
    "Rebol",
    "Red",
    "Redcode",
    "Ren'Py",
    "RenderScript",
    "reStructuredText",
    "REXX",
    "RHTML",
    "RMarkdown",
    "RobotFramework",
    "Rouge",
    "RPM Spec",
    "RUNOFF",
    "Rust",
    "Sage",
    "SaltStack",
    "SAS",
    "Sass",
    "Scaml",
    "Scheme",
    "Scilab",
    "SCSS",
    "Self",
    "ShellSession",
    "Shen",
    "Slash",
    "Slim",
    "Smali",
    "Smalltalk",
    "Smarty",
    "SMT",
    "SourcePawn",
    "SPARQL",
    "Spline Font Database",
    "SQF",
    "SQL",
    "SQLPL",
    "Squirrel",
    "SRecode Template",
    "Stan",
    "Standard ML",
    "Stata",
    "STON",
    "Stylus",
    "Sublime Text Config",
    "SubRip Text",
    "SuperCollider",
    "SVG",
    "SystemVerilog",
    "Tcl",
    "Tcsh",
    "Tea",
    "Terra",
    "Text",
    "Textile",
    "Thrift",
    "TI Program",
    "TLA",
    "TOML",
    "Turing",
    "Turtle",
    "Twig",
    "TXL",
    "TypeScript",
    "Unified Parallel C",
    "Unity3D Asset",
    "Uno",
    "UnrealScript",
    "UrWeb",
    "Vala",
    "VCL",
    "Verilog",
    "VHDL",
    "Visual Basic",
    "Volt",
    "Vue",
    "Wavefront Material",
    "Wavefront Object",
    "Web Ontology Language",
    "WebIDL",
    "wisp",
    "World of Warcraft Addon Data",
    "X10",
    "xBase",
    "XC",
    "XML",
    "Xojo",
    "XPages",
    "XProc",
    "XQuery",
    "XS",
    "XSLT",
    "Xtend",
    "Yacc",
    "YAML",
    "YANG",
    "Zephir",
    "Zimpl"
  ]

  @lang_length = @languages.count
  @curr_lang_count = 0

  class << self
    def paginate_repos(skip_to_star: nil)
      # Set initial kickoff url to paginate from
      @start_time = Time.now
      if skip_to_star
        @star_count = skip_to_star.to_i
        @current_url = @BASE_URL + "?q=stars:#{@star_count}"
        @first_round_of_pagination = false
      else
        @first_round_of_pagination = true
        @current_url = @BASE_URL + "?q=stars:>1&sort=stars&order=desc"
      end

      loop do
        loop do
          @resp = search_request
          puts "Search request to #{@current_url}"

          if rate_requests_remain?
            @query_by_language ? handle_stars_and_languages : handle_stars_request
          else
            break
          end
        end

        wait_time = Time.at(seconds_to_reset) - Time.now

        if abuse_error?
          puts "Sleeping due to abuse error"
          sleep @resp.headers['retry-after'].to_i
          next
        end

        puts "Time until reset: #{Time.at(seconds_to_reset)}"
        puts "Current time: #{Time.now.to_s}"

        puts "Out of requests... Sleeping ~#{wait_time} s"

        sleep wait_time unless wait_time.negative?
      end
    end

    private

    def handle_request
      if @first_round_of_pagination
        handle_first_round_of_pagination
      else
        handle_stars_request
      end
    end

    def handle_first_round_of_pagination
      @resp = search_request
      @parsed_repos = JSON.parse(@resp.body)['items']

      puts "Request: #{@current_url}"

      process_repos

      if last_pagination?
        @star_count = @parsed_repos.last['stargazers_count'].to_i
        @current_url = @BASE_URL + "?q=stars:#{@star_count}"
        @first_round_of_pagination = false
      else
        @current_url = @resp.headers['link'].split(',').first.split(';').first[/(?<=<).*(?=>)/]
      end
    end

    def handle_stars_request
      @parsed_repos = JSON.parse(@resp.body)['items']
      if no_repos_for_star_count?
        @current_url = @BASE_URL + "?q=stars:#{@star_count -= 1}"
        return
      end

      if first_pagination?
        @repos_processed_for_curr_pagination = 0
      end

      puts "Request: #{@current_url}"

      process_repos

      @repos_processed_for_curr_pagination += @parsed_repos.count
      if next_pagination?
        @current_url = @resp.headers['link'].split(',').first.split(';').first[/(?<=<).*(?=>)/]
      elsif repeat_pagination?
        puts "Aborting due to repeating loop"
        @current_url = @BASE_URL + "?q=stars:#{@star_count}+#{URI.encode_www_form('language': next_lang).sub('=',':')}"
        @query_by_language = true
      elsif last_pagination?
        @current_url = @BASE_URL + "?q=stars:#{@star_count -= 1}"
      end
    end

    def handle_stars_and_languages
      @parsed_repos = JSON.parse(@resp.body)['items']
      if no_repos_for_star_count?
        if @curr_lang_count >= @lang_length
          @curr_lang_count = 0
          @current_url = @BASE_URL + "?q=stars:#{@star_count -= 1}+#{URI.encode_www_form('language': next_lang).sub('=',':')}"
        else
          @current_url = @BASE_URL + "?q=stars:#{@star_count}+#{URI.encode_www_form('language': next_lang).sub('=',':')}"
        end
        @curr_lang_count += 1
        return
      end

      if first_pagination?
        @repos_processed_for_curr_pagination = 0
      end

      puts "Request: #{@current_url}"

      process_repos

      @repos_processed_for_curr_pagination += @parsed_repos.count
      if next_pagination?
        @current_url = @resp.headers['link'].split(',').first.split(';').first[/(?<=<).*(?=>)/]
      elsif repeat_pagination?
        puts "Aborting due to repeating loop"
        abort
      elsif last_pagination?
        @current_url = @BASE_URL + "?q=stars:#{@star_count}+#{URI.encode_www_form('language': next_lang).sub('=',':')}"
        @curr_lang_count += 1
        if @curr_lang_count >= @lang_length
          @curr_lang_count = 0
          @current_url = @BASE_URL + "?q=stars:#{@star_count -= 1}+#{URI.encode_www_form('language': next_lang).sub('=',':')}"
        end
      end

    end

    def next_lang
      lang = @languages.shift
      @languages.push lang
      lang
    end

    def curr_lang
      @languages.first
    end

    def no_repos_for_star_count?
      @parsed_repos && @parsed_repos.empty?
    end

    def first_pagination?
      @resp.headers['link'] && !@resp.headers['link'].include?('rel="first"') || !@resp.headers['link']
    end

    def next_pagination?
      @resp.headers['link'] && @resp.headers['link'].include?('rel="next"')
    end

    def repeat_pagination?
      last_pagination? && @repos_processed_for_curr_pagination >= REPOS_PROCESSED_PAGINATION_MAX
    end

    def last_pagination?
      @resp.headers['link'] && !@resp.headers['link'].include?('rel="last"') || !@resp.headers['link']
    end

    def process_repos
      # TODO: Change this to upsert data
      puts "Processing #{@parsed_repos.count} Repositories."
      repos = @parsed_repos.map do |repo|
        Repository.new({
          name: repo['name'],
          github_id: repo['id'],
          url: repo['html_url'],
          language: repo['language'],
          stars:  repo['stargazers_count'],
          forks:  repo['forks']
        })
      end
      Repository.import(repos)
      puts "#{@repos_processed += @parsed_repos.count} Repositories Processed in #{minutes_running} minutes."
    end

    def minutes_running
      ((Time.now - @start_time) / 60).round(2)
    end

    def search_request
      Faraday.get(@current_url) do |req|
        req.headers['Authorization'] = "token #{@access_token}"
        req.headers['Accept'] = 'application/vnd.github.v3+json'
      end
    end

    def rate_requests_remain?
      requests_remaining > 0
    end

    def requests_remaining
      @resp.headers['x-ratelimit-remaining'].to_i
    end

    def seconds_to_reset
      @resp.headers['x-ratelimit-reset'].to_i
    end

    def abuse_error?
      seconds_to_reset == 0
    end
  end
end
