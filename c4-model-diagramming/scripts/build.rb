#!/usr/bin/env ruby
# frozen_string_literal: true

# Writes every key element and one example per diagram type as SVG files.
#
#   ruby scripts/build.rb            # writes into references/keys and references/examples
#   ruby scripts/build.rb OUT_DIR    # writes into OUT_DIR/keys and OUT_DIR/examples

require "fileutils"
require_relative "c4"

module C4
  module Build
    KEYS = {
      "person" => [220, 170, "Person", ->(d) { d.person(50, 10, 120, 130, "Sales agent", ["Answers customers"]) }],
      "software-system" => [240, 120, "Software system", ->(d) { d.system(20, 20, 200, 80, "Order desk", ["Takes and tracks orders"]) }],
      "external-system" => [240, 120, "External system", ->(d) { d.external(20, 20, 200, 80, "Payment provider", ["Settles card payments"]) }],
      "container" => [240, 130, "Container", ->(d) { d.container(20, 20, 200, 90, "API application", "Ruby on Rails", ["Serves the order endpoints"]) }],
      "container-database" => [240, 130, "Database container", ->(d) { d.database(40, 12, 160, 106, "Orders database", "Container · PostgreSQL", ["Orders and shipments"]) }],
      "container-bucket" => [240, 130, "Object store container", ->(d) { d.bucket(40, 12, 160, 106, "Document store", "Container · S3", ["Signed order PDFs"]) }],
      "container-directory" => [240, 130, "Directory container", ->(d) { d.directory(30, 12, 180, 106, "Export folder", "Container · File system", ["Nightly CSV exports"]) }],
      "container-web-browser" => [240, 130, "Browser application container", ->(d) { d.browser(20, 12, 200, 106, "Order desk web app", "Container · React", ["Order search and status"]) }],
      "container-console" => [240, 120, "Server-side or console container", ->(d) { d.console(20, 20, 200, 80, "Sync worker", "Container · Ruby", ["Pulls orders every 15 min"]) }],
      "component" => [250, 120, "Component", ->(d) { d.component(30, 20, 200, 80, "Order lookup", "Rails model", ["Finds an order by number"]) }],
      "boundary" => [260, 130, "Boundary", ->(d) { d.boundary(20, 15, 220, 100, "Order desk", "Software system").container(45, 52, 180, 50, "API application", "Rails") }],
      "group" => [260, 150, "Group", ->(d) { d.group(20, 15, 220, 120, "Sales department").person(70, 18, 120, 92, "Sales agent") }],
      "deployment-node" => [260, 140, "Deployment node", ->(d) { d.node(20, 12, 220, 116, "Application server", "Ubuntu 24.04", instances: 2).container(40, 26, 180, 50, "API application", "Rails") }],
      "infrastructure-node" => [260, 120, "Infrastructure node", ->(d) { d.infra(20, 15, 220, 90, "Load balancer", "Nginx") }],
      "relationship" => [260, 90, "Relationship", ->(d) { d.rel("20,40 240,40", "Reads order status from", tech: "JSON/HTTPS", lx: 130, ly: 28) }],
      "relationship-numbered" => [260, 90, "Numbered relationship", ->(d) { d.rel("20,40 240,40", "Looks up the order", tech: "SQL", lx: 140, ly: 28).step(28, 40, 1) }],
      "candidate" => [250, 120, "Candidate element", ->(d) { d.component(30, 20, 200, 80, "Shipping forecast", "candidate", ["Not yet decided"], hue: :candidate, dashed: true) }]
    }.freeze

    def self.write(out_dir)
      keys_dir = File.join(out_dir, "keys")
      examples_dir = File.join(out_dir, "examples")
      FileUtils.mkdir_p([keys_dir, examples_dir])
      KEYS.each do |name, (w, h, label, draw)|
        File.write(File.join(keys_dir, "#{name}.svg"), C4.draw(w, h, "Key: #{label}") { |d| draw.call(d) })
      end
      Examples.all.each { |name, svg| File.write(File.join(examples_dir, "#{name}.svg"), svg) }
      Dir.glob(File.join(out_dir, "{keys,examples}", "*.svg")).sort
    end
  end

  # Six example diagrams for one fictional company: the order desk of a trading firm.
  module Examples
    PERSON_KEY = ["Person", :person].freeze
    SYSTEM_KEY = ["Software system", :system].freeze
    EXTERNAL_KEY = ["External system", :external].freeze
    CONTAINER_KEY = ["Container", :container].freeze
    STORE_KEY = ["Data store", :store].freeze
    COMPONENT_KEY = ["Component", :component].freeze
    CANDIDATE_KEY = ["Candidate container", :candidate, true].freeze
    NODE_KEY = ["Deployment node", :node].freeze

    def self.all
      {
        "system-context" => system_context, "container" => container, "component" => component,
        "system-landscape" => system_landscape, "dynamic" => dynamic, "deployment" => deployment
      }
    end

    def self.system_context
      C4.draw(920, 460, "System context diagram for the order desk") do |d|
        d.title(30, 34, "System context", "Order desk · who uses it and what it talks to")
        d.person(60, 110, 150, 160, "Sales agent", ["Confirms orders", "for customers"])
        d.system(360, 130, 220, 110, "Order desk", ["Answers questions about", "customer orders"])
        d.external(720, 80, 170, 80, "ERP", ["Orders, stock, invoices"])
        d.external(720, 190, 170, 80, "Company sign-in", ["Identity provider"])
        d.external(720, 320, 170, 80, "Email service", ["Delivers notices"])
        d.rel("210,190 360,190", "Asks about orders", tech: "HTTPS", lx: 285, ly: 172)
        d.path("M580 160 L640 160 L640 120 L720 120", "Reads orders from", tech: "REST/JSON", lx: 655, ly: 108)
        d.rel("580,230 720,230", "Verifies users with", tech: "OpenID Connect", lx: 650, ly: 218)
        d.path("M490 240 L490 360 L720 360", "Sends daily digests through", tech: "SMTP", lx: 605, ly: 348)
        d.key(30, 440, [PERSON_KEY, SYSTEM_KEY, EXTERNAL_KEY])
      end
    end

    def self.container
      C4.draw(1000, 580, "Container diagram for the order desk") do |d|
        d.title(30, 34, "Container diagram", "Order desk · applications and data stores inside the system")
        d.person(40, 110, 140, 150, "Sales agent", ["Confirms orders"])
        d.boundary(250, 80, 440, 440, "Order desk", "Software system")
        d.browser(280, 130, 170, 90, "Web app", "Container · React", ["Order search"])
        d.container(520, 130, 150, 90, "API", "Rails", ["Order endpoints"])
        d.container(260, 274, 200, 100, "Answer service", "Ruby · candidate", ["Calls a language", "model API"], hue: :candidate, dashed: true)
        d.database(520, 270, 150, 100, "Orders DB", "Container · PostgreSQL", ["Order copies"])
        d.console(520, 410, 150, 80, "Sync worker", "Container · Ruby", ["Pulls orders"])
        d.external(770, 130, 180, 80, "Company sign-in", ["Identity provider"])
        d.external(770, 410, 180, 80, "ERP", ["Orders and stock"])
        d.rel("180,180 280,170", "Uses", tech: "HTTPS", lx: 230, ly: 152)
        d.rel("450,165 520,165", "Calls", tech: "JSON/HTTPS", lx: 485, ly: 118)
        d.rel("670,165 770,165", "Checks tokens with", tech: "OpenID Connect", lx: 720, ly: 118)
        d.rel("595,220 595,270", "Reads and writes", tech: "SQL", lx: 607, ly: 242, anchor: "start")
        d.path("M560 220 L560 234 L360 234 L360 274", "Asks for an answer · trial", tech: "JSON/HTTP", lx: 470, ly: 253, dashed: true)
        d.rel("460,322 520,322", "Reads from", tech: "SQL", lx: 490, ly: 306)
        d.rel("595,410 595,370", "Writes to", tech: "SQL", lx: 607, ly: 388, anchor: "start")
        d.rel("670,450 770,450", "Pulls orders from", tech: "REST/JSON", lx: 720, ly: 436)
        d.key(30, 560, [PERSON_KEY, CONTAINER_KEY, STORE_KEY, EXTERNAL_KEY, CANDIDATE_KEY])
      end
    end

    def self.component
      C4.draw(960, 520, "Component diagram for the API container") do |d|
        d.title(30, 34, "Component diagram", "API container · the parts that answer an order question")
        d.boundary(40, 70, 620, 410, "API", "Container · Rails")
        d.component(80, 140, 170, 90, "Question endpoint", "Rails controller", ["Receives a question"])
        d.component(430, 140, 190, 90, "Intent reader", "Ruby", ["Finds the order number", "with a language model API"])
        d.component(80, 310, 170, 90, "Order lookup", "Rails model", ["Loads the order"])
        d.component(430, 310, 190, 90, "Answer writer", "Ruby", ["Writes one sentence", "with the source"])
        d.browser(730, 120, 170, 90, "Web app", "Container · React")
        d.database(730, 300, 170, 110, "Orders DB", "Container · PostgreSQL")
        d.path("M730 150 L690 150 L690 100 L165 100 L165 140", "Sends a question to", tech: "JSON/HTTPS", lx: 440, ly: 94)
        d.rel("250,180 430,180", "Asks the meaning of", lx: 335, ly: 170)
        d.path("M525 230 L525 265 L165 265 L165 310", "Hands the order number to", lx: 345, ly: 258)
        d.rel("250,350 430,350", "Gives the order to", lx: 335, ly: 340)
        d.path("M165 400 L165 430 L815 430 L815 410", "Reads the order from", tech: "SQL", lx: 500, ly: 423)
        d.key(30, 500, [COMPONENT_KEY, CONTAINER_KEY, STORE_KEY])
      end
    end

    def self.system_landscape
      C4.draw(980, 480, "System landscape for the trading firm") do |d|
        d.title(30, 34, "System landscape", "Trading firm · every system the sales and operations teams touch")
        d.group(40, 70, 730, 370, "Trading firm")
        d.person(80, 110, 130, 140, "Sales agent")
        d.person(80, 270, 130, 140, ["Operations", "planner"])
        d.system(320, 120, 180, 90, "Order desk", ["Order questions"])
        d.system(320, 280, 180, 90, "Shipment planner", ["Load and route plans"])
        d.system(580, 200, 160, 90, "ERP", ["Orders, stock, invoices"])
        d.external(820, 120, 130, 70, "Carrier portal")
        d.external(820, 310, 130, 70, "Bank")
        d.rel("210,180 320,170", "Asks", lx: 262, ly: 162)
        d.rel("210,340 320,330", "Plans in", lx: 262, ly: 322)
        d.rel("500,175 580,225", "Reads from", lx: 548, ly: 188)
        d.rel("500,335 580,275", "Reads from", lx: 548, ly: 322)
        d.path("M500 300 L785 300 L785 155 L820 155", "Books loads with", tech: "EDI", lx: 795, ly: 235, anchor: "start")
        d.path("M660 290 L660 345 L820 345", "Pays through", tech: "SWIFT", lx: 740, ly: 326)
        d.key(30, 460, [PERSON_KEY, SYSTEM_KEY, EXTERNAL_KEY])
      end
    end

    def self.dynamic
      C4.draw(960, 460, "Dynamic diagram: answering whether an order is confirmed") do |d|
        d.title(30, 34, "Dynamic diagram", "Order desk · \"Is SO-1042 confirmed?\" from question to answer")
        d.person(20, 120, 130, 140, "Sales agent")
        d.browser(240, 150, 140, 90, "Web app", "Container · React")
        d.container(500, 150, 140, 90, "API", "Rails")
        d.database(760, 140, 150, 110, "Orders DB", "Container · PostgreSQL")
        d.external(490, 330, 160, 90, "Language model API", ["Reads the question"])
        d.rel("150,200 240,200", "Asks a question", lx: 195, ly: 180).step(165, 200, 1)
        d.rel("380,195 500,195", "Posts the question", tech: "JSON/HTTPS", lx: 440, ly: 165).step(398, 195, 2)
        d.rel("570,240 570,330", "Asks for the order number", tech: "HTTPS", lx: 582, ly: 290, anchor: "start").step(570, 262, 3)
        d.rel("640,185 760,185", "Loads the order", tech: "SQL", lx: 700, ly: 165).step(658, 185, 4)
        d.path("M500 215 L380 215", "Returns the answer", tech: "JSON", lx: 440, ly: 242).step(482, 215, 5)
        d.key(30, 440, [PERSON_KEY, CONTAINER_KEY, STORE_KEY, EXTERNAL_KEY, ["Step", :candidate]])
      end
    end

    def self.deployment
      C4.draw(960, 590, "Deployment diagram for the order desk, production") do |d|
        d.title(30, 34, "Deployment diagram", "Order desk · production")
        d.node(40, 80, 260, 170, "Agent's laptop", "macOS or Windows")
        d.node(70, 100, 200, 90, "Web browser", "Chrome, Edge")
        d.container(95, 108, 150, 50, "Web app", "React")
        d.node(340, 80, 580, 460, "Company cloud account", "AWS eu-central-1")
        d.infra(380, 110, 180, 70, "Load balancer", "ALB")
        d.node(370, 230, 230, 130, "App server", "Ubuntu 24.04, t3.medium", instances: 2)
        d.container(390, 245, 175, 50, "API", "Rails")
        d.node(680, 230, 240, 140, "Database server", "Amazon RDS")
        d.database(710, 236, 190, 82, "Orders DB", "Container · PostgreSQL 16")
        d.node(370, 390, 230, 100, "Worker", "Ubuntu 24.04, t3.small", instances: 1)
        d.console(390, 402, 175, 46, "Sync worker", "Container · Ruby")
        d.rel("245,130 388,130", "Calls", tech: "HTTPS", lx: 315, ly: 117)
        d.rel("470,180 470,245", "Forwards to", tech: "HTTP", lx: 482, ly: 212, anchor: "start")
        d.rel("565,270 710,270", "Reads and writes", tech: "SQL", lx: 638, ly: 256)
        d.path("M565 425 L860 425 L860 318", "Writes to", tech: "SQL", lx: 848, ly: 385, anchor: "end")
        d.key(30, 570, [CONTAINER_KEY, STORE_KEY, NODE_KEY])
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  out = ARGV.first || File.expand_path("../references", __dir__)
  C4::Build.write(out).each { |file| puts file }
end
