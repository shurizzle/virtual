# using gem as backend

require 'nokogiri'

repository.do {
  def each_package (&block)
    dom = Nokogiri::XML.parse(filesystem.data.to_s)

    `gem list --remote`.lines.each {|line|
      CLI.info "Parsing `#{line.chomp}`" if System.env[:VERBOSE]

      t, name, version = line.match(/^(.+?) \((.+?)\)$/).to_a

      unless name && version
        CLI.warn "`#{line.chomp}` was not parsed succesfully" if System.env[:VERBOSE]
        next
      end

      begin
        Versionomy.parse(version, :rubygems)
      rescue Versionomy::Errors::ParseError => e
        version.sub!(e.message.match(/Extra characters: "(.*?)"/).to_a.last, '')

        begin
          Versionomy.parse(version, :rubygems)
        rescue Versionomy::Errors::ParseError
          if System.env[:VERBOSE]
            require 'packo/cli'

            CLI.warn("Problem parsing #{name}")
          end

          next
        end
      end

      block.call(Package.new(
        tags:    ['ruby', 'gem'] + ((dom.xpath(%{//gem[name = "#{name}"]/tags}).first.text.split(/\s+/) rescue nil) || []),
        name:    name,
        version: Versionomy.parse(version, :rubygems)
      ))
    }
  end

  def install (name)

  end

  def uninstall (name)

  end
}

__END__
$$$

$$$ data $$$

<data>
  <gem name="dm-sqlite-adapter">
    <tags>datamapper database</tags>

    <dependency>database/sqlite</dependency>
  </gem>
</data>