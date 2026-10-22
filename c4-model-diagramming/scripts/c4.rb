# frozen_string_literal: true

# Draws C4 model diagrams as standalone SVG: the notation shapes, relationships, boundaries,
# numbered steps, and a key. Colors are CSS tokens declared inside each SVG, with a dark set.
#
#   require_relative "c4"
#   svg = C4.draw(900, 400, "System context for the order desk") do |d|
#     d.person(40, 60, 180, 150, "Customer", ["Places orders"])
#     d.system(400, 90, 240, 120, "Order desk", ["Takes and tracks orders"])
#     d.rel("220,150 400,150", "Places orders with", tech: "HTTPS")
#     d.key(40, 380, [["Person", :person], ["Software system", :system]])
#   end
module C4
  LIGHT = {
    ground: "#F7F6F3", raised: "#FFFFFF", sunk: "#EDEBE6", ink: "#1A1D23", "ink-soft": "#3D434E",
    muted: "#6B7285", rule: "#DCD9D2", primary: "#2E7D76", "primary-soft": "#D7EBE8",
    accent: "#B77914", "accent-soft": "#F5E6C9", person: "#5B5FA8", "person-soft": "#E2E3F4"
  }.freeze
  DARK = {
    ground: "#12151A", raised: "#191D24", sunk: "#0D1014", ink: "#E8E6E1", "ink-soft": "#BFC3CC",
    muted: "#8B92A5", rule: "#272C36", primary: "#4FA8A0", "primary-soft": "#102A28",
    accent: "#E0A33E", "accent-soft": "#33280F", person: "#9BA0E0", "person-soft": "#1A1B33"
  }.freeze
  FONT = '"Bricolage Grotesque","Helvetica Neue",Arial,sans-serif'

  HUES = {
    person: "fill:var(--person-soft);stroke:var(--person)",
    system: "fill:var(--primary-soft);stroke:var(--primary)",
    external: "fill:var(--sunk);stroke:var(--muted)",
    container: "fill:var(--raised);stroke:var(--ink)",
    store: "fill:var(--primary-soft);stroke:var(--primary)",
    component: "fill:var(--raised);stroke:var(--ink)",
    candidate: "fill:var(--accent-soft);stroke:var(--accent)",
    node: "fill:none;stroke:var(--ink-soft)",
    base: "fill:var(--primary-soft);stroke:var(--primary)"
  }.freeze

  def self.esc(text) = text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")

  def self.tokens(set) = set.map { |k, v| "--#{k}:#{v}" }.join(";")

  def self.draw(width, height, label, &block)
    d = Drawing.new
    block.call(d)
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{width} #{height}" width="#{width}" height="#{height}" role="img" aria-label="#{esc(label)}" font-family='#{FONT}' fill="var(--ink)">
      <title>#{esc(label)}</title>
      <style>svg{#{tokens(LIGHT)}}@media (prefers-color-scheme:dark){svg{#{tokens(DARK)}}}</style>
      <defs><marker id="c4-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0L10 5L0 10z" fill="var(--ink)"/></marker></defs>
      <rect width="#{width}" height="#{height}" fill="var(--ground)"/>
      #{d.out}</svg>
    SVG
  end

  # One drawing. Every method appends SVG and returns self, so calls chain.
  class Drawing
    attr_reader :out

    def initialize = @out = +""

    def esc(text) = C4.esc(text)

    def hue(name) = HUES.fetch(name)

    def dash(dashed) = dashed ? ' stroke-dasharray="7 5"' : ""

    # Name on one or more lines, the type in brackets, then description lines.
    def label(cx, y, name, kind, lines, size: 14)
      ty = y
      Array(name).each_with_index do |n, i|
        ty += 17 if i.positive?
        @out << %(<text x="#{cx}" y="#{ty}" font-size="#{size}" font-weight="700" text-anchor="middle">#{esc(n)}</text>)
      end
      if kind
        ty += 16
        @out << %(<text x="#{cx}" y="#{ty}" font-size="10.5" text-anchor="middle" fill="var(--muted)">[#{esc(kind)}]</text>)
      end
      Array(lines).each do |l|
        ty += 15
        @out << %(<text x="#{cx}" y="#{ty}" font-size="11.5" text-anchor="middle" fill="var(--ink-soft)">#{esc(l)}</text>)
      end
      self
    end

    def title(x, y, text, sub = nil)
      @out << %(<text x="#{x}" y="#{y}" font-size="11" font-weight="700" letter-spacing="1.2" fill="var(--muted)">#{esc(text.upcase)}</text>)
      @out << %(<text x="#{x}" y="#{y + 16}" font-size="11.5" fill="var(--ink-soft)">#{esc(sub)}</text>) if sub
      self
    end

    # A rounded box: software system, container, component, external system, candidate.
    def box(x, y, w, h, name, kind, lines = [], hue: :container, dashed: false, rx: 6)
      @out << %(<rect x="#{x}" y="#{y}" width="#{w}" height="#{h}" rx="#{rx}" style="#{hue(hue)}" stroke-width="1.4"#{dash(dashed)}/>)
      label(x + w / 2.0, y + 24, name, kind, lines)
    end

    def system(x, y, w, h, name, lines = [], kind: "Software system", hue: :system, dashed: false)
      box(x, y, w, h, name, kind, lines, hue: hue, dashed: dashed)
    end

    def external(x, y, w, h, name, lines = [], kind: "External system", dashed: false)
      box(x, y, w, h, name, kind, lines, hue: :external, dashed: dashed)
    end

    def container(x, y, w, h, name, tech, lines = [], hue: :container, dashed: false)
      box(x, y, w, h, name, "Container · #{tech}", lines, hue: hue, dashed: dashed)
    end

    # A component: a box with the two small tabs on its left edge.
    def component(x, y, w, h, name, tech, lines = [], hue: :component, dashed: false)
      box(x, y, w, h, name, "Component · #{tech}", lines, hue: hue, dashed: dashed)
      [10, 26].each do |dy|
        @out << %(<rect x="#{x - 7}" y="#{y + dy}" width="14" height="9" rx="2" style="#{hue(hue)}" stroke-width="1.2"/>)
      end
      self
    end

    # A person: a head about two fifths of the box width on a rounded body with two arm lines.
    def person(x, y, w, h, name, lines = [], hue: :person, dashed: false)
      r = (w * 0.19).round
      cx = x + w / 2.0
      top = y + (1.6 * r).round
      body = y + h - top
      @out << %(<rect x="#{x}" y="#{top}" width="#{w}" height="#{body}" rx="18" style="#{hue(hue)}" stroke-width="1.4"#{dash(dashed)}/>)
      @out << %(<circle cx="#{cx}" cy="#{y + r}" r="#{r}" style="#{hue(hue)}" stroke-width="1.4"#{dash(dashed)}/>)
      [0.2, 0.8].each do |f|
        ax = (x + w * f).round
        @out << %(<line x1="#{ax}" y1="#{(top + body * 0.62).round}" x2="#{ax}" y2="#{y + h - 10}" stroke="var(--muted)" stroke-width="0.8" opacity="0.6"/>)
      end
      label(cx, top + 26, name, "Person", lines)
    end

    # A data store: a cylinder.
    def database(x, y, w, h, name, kind, lines = [], hue: :store, dashed: false)
      ry = 9
      @out << %(<path d="M#{x} #{y + ry} v#{h - 2 * ry} a#{w / 2.0} #{ry} 0 0 0 #{w} 0 v-#{h - 2 * ry}" style="#{hue(hue)}" stroke-width="1.4"#{dash(dashed)}/>)
      @out << %(<ellipse cx="#{x + w / 2.0}" cy="#{y + ry}" rx="#{w / 2.0}" ry="#{ry}" style="#{hue(hue)}" stroke-width="1.4"#{dash(dashed)}/>)
      label(x + w / 2.0, y + 34, name, kind, lines)
    end

    # An object store: a bucket, wider at the top.
    def bucket(x, y, w, h, name, kind, lines = [], hue: :store, dashed: false)
      ry = 9
      inset = (w * 0.08).round
      @out << %(<path d="M#{x} #{y + ry} L#{x + inset} #{y + h - ry} a#{w / 2.0 - inset} #{ry} 0 0 0 #{w - 2 * inset} 0 L#{x + w} #{y + ry}" style="#{hue(hue)}" stroke-width="1.4"#{dash(dashed)}/>)
      @out << %(<ellipse cx="#{x + w / 2.0}" cy="#{y + ry}" rx="#{w / 2.0}" ry="#{ry}" style="#{hue(hue)}" stroke-width="1.4"#{dash(dashed)}/>)
      label(x + w / 2.0, y + 34, name, kind, lines)
    end

    # A directory: a folder with a tab.
    def directory(x, y, w, h, name, kind, lines = [], hue: :container, dashed: false)
      @out << %(<path d="M#{x} #{y + 12} h#{(w * 0.3).round} l6 -10 h#{(w * 0.2).round} l6 10 h#{w - (w * 0.3).round - (w * 0.2).round - 12} v#{h - 12} h-#{w} z" style="#{hue(hue)}" stroke-width="1.4" stroke-linejoin="round"#{dash(dashed)}/>)
      label(x + w / 2.0, y + 36, name, kind, lines)
    end

    # A client-side application: a browser window with a title bar.
    def browser(x, y, w, h, name, kind, lines = [], hue: :container, dashed: false)
      box(x, y, w, h, nil, nil, [], hue: hue, dashed: dashed)
      @out << %(<line x1="#{x}" y1="#{y + 18}" x2="#{x + w}" y2="#{y + 18}" style="#{hue(hue)}" stroke-width="1.2"/>)
      [10, 22, 34].each { |dx| @out << %(<circle cx="#{x + dx}" cy="#{y + 9}" r="3" fill="var(--muted)"/>) }
      label(x + w / 2.0, y + 40, name, kind, lines)
    end

    # A command or server-side process: a box with a prompt mark.
    def console(x, y, w, h, name, kind, lines = [], hue: :container, dashed: false)
      box(x, y, w, h, name, kind, lines, hue: hue, dashed: dashed)
      @out << %(<text x="#{x + 10}" y="#{y + 17}" font-size="12" font-weight="700" fill="var(--muted)" font-family="ui-monospace,Menlo,monospace">&gt;_</text>)
      self
    end

    # A scope boundary: dashed, labelled at the top left.
    def boundary(x, y, w, h, name, kind = nil, hue: :system)
      stroke = hue(hue).split(";").last
      @out << %(<rect x="#{x}" y="#{y}" width="#{w}" height="#{h}" rx="10" fill="none" style="#{stroke}" stroke-width="1.3" stroke-dasharray="7 5"/>)
      @out << %(<text x="#{x + 14}" y="#{y + 19}" font-size="12" font-weight="700">#{esc(name)}</text>)
      @out << %(<text x="#{x + 14}" y="#{y + 33}" font-size="10.5" fill="var(--muted)">[#{esc(kind)}]</text>) if kind
      self
    end

    # A group of elements that is not a software boundary: dotted, labelled at the bottom left.
    def group(x, y, w, h, name)
      @out << %(<rect x="#{x}" y="#{y}" width="#{w}" height="#{h}" fill="none" stroke="var(--ink-soft)" stroke-width="1.3" stroke-dasharray="2 4"/>)
      @out << %(<text x="#{x + 14}" y="#{y + h - 12}" font-size="12" font-weight="700">#{esc(name)}</text>)
      self
    end

    # A deployment node: solid, labelled at the bottom left, nested as needed.
    def node(x, y, w, h, name, kind, instances: nil)
      @out << %(<rect x="#{x}" y="#{y}" width="#{w}" height="#{h}" rx="8" style="#{hue(:node)}" stroke-width="1.3"/>)
      @out << %(<text x="#{x + 14}" y="#{y + h - 24}" font-size="12" font-weight="700">#{esc(name)}</text>)
      @out << %(<text x="#{x + 14}" y="#{y + h - 10}" font-size="10.5" fill="var(--muted)">[Deployment node · #{esc(kind)}]</text>)
      @out << %(<text x="#{x + w - 14}" y="#{y + 20}" font-size="13" font-weight="700" text-anchor="end" fill="var(--muted)">x#{esc(instances)}</text>) if instances
      self
    end

    # An infrastructure node: an ellipse.
    def infra(x, y, w, h, name, kind, lines = [])
      @out << %(<ellipse cx="#{x + w / 2.0}" cy="#{y + h / 2.0}" rx="#{w / 2.0}" ry="#{h / 2.0}" style="#{hue(:node)}" stroke-width="1.3"/>)
      label(x + w / 2.0, y + h / 2.0 - 10, name, "Infrastructure node · #{kind}", lines)
    end

    def halo = 'style="paint-order:stroke;stroke:var(--ground);stroke-width:5px;stroke-linejoin:round"'

    def rel_label(lx, ly, label, tech, anchor)
      @out << %(<text x="#{lx}" y="#{ly}" font-size="11.5" text-anchor="#{anchor}" #{halo}>#{esc(label)}</text>)
      @out << %(<text x="#{lx}" y="#{ly + 13}" font-size="10" text-anchor="#{anchor}" fill="var(--muted)" #{halo}>[#{esc(tech)}]</text>) if tech
    end

    # A relationship: one direction, a label that says what happens, a technology in brackets.
    def rel(points, label = nil, lx: nil, ly: nil, anchor: "middle", tech: nil, dashed: false, solid: false)
      style = dashed ? ' stroke-dasharray="5 4"' : ""
      width = solid ? 2 : 1.3
      @out << %(<polyline points="#{points}" fill="none" stroke="var(--ink)" stroke-width="#{width}" marker-end="url(#c4-arrow)"#{style}/>)
      rel_label(lx, ly, label, tech, anchor) if label
      self
    end

    # A relationship along an SVG path, for bends and hops over crossings.
    def path(d, label = nil, lx: nil, ly: nil, anchor: "middle", tech: nil, dashed: false)
      style = dashed ? ' stroke-dasharray="5 4"' : ""
      @out << %(<path d="#{d}" fill="none" stroke="var(--ink)" stroke-width="1.3" marker-end="url(#c4-arrow)"#{style}/>)
      rel_label(lx, ly, label, tech, anchor) if label
      self
    end

    # A numbered step marker for a dynamic diagram.
    def step(cx, cy, n)
      @out << %(<circle cx="#{cx}" cy="#{cy}" r="11" style="#{hue(:candidate)}" stroke-width="1.4"/>)
      @out << %(<text x="#{cx}" y="#{cy + 4}" font-size="11" font-weight="800" text-anchor="middle">#{n}</text>)
      self
    end

    def text(x, y, s, size: 11.5, weight: 400, anchor: "start", soft: false)
      @out << %(<text x="#{x}" y="#{y}" font-size="#{size}" font-weight="#{weight}" text-anchor="#{anchor}"#{soft ? ' fill="var(--ink-soft)"' : ""}>#{esc(s)}</text>)
      self
    end

    # The key: a swatch per element kind the diagram uses.
    def key(x, y, items)
      @out << %(<text x="#{x}" y="#{y}" font-size="11.5" font-weight="700">Key</text>)
      cx = x + 40
      items.each do |(name, hue, dashed)|
        extra = dashed ? ' stroke-dasharray="4 3"' : ""
        @out << %(<rect x="#{cx}" y="#{y - 12}" width="26" height="16" rx="3" style="#{hue(hue)}" stroke-width="1.5"#{extra}/>)
        @out << %(<text x="#{cx + 33}" y="#{y}" font-size="11.5">#{esc(name)}</text>)
        cx += 33 + name.length * 6.4 + 22
      end
      self
    end
  end
end
