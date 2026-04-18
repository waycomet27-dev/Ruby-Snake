# frozen_string_literal: true

# Windowed Snake — requires: gem install glimmer-dsl-libui
# Run: ruby rubysnake_gui.rb

require 'glimmer-dsl-libui'

class RubysnakeGui
  include Glimmer

  GRID_W = 20
  GRID_H = 15
  CELL = 26
  PAD = 16
  HUD_H = 52
  TICK = 0.14

  COL_BG     = { r: 22,  g: 33,  b: 62,  a: 1.0 }
  COL_GRID   = { r: 15,  g: 52,  b: 96,  a: 0.55 }
  COL_HEAD   = { r: 0,   g: 255, b: 157, a: 1.0 }
  COL_BODY   = { r: 78,  g: 204, b: 163, a: 1.0 }
  COL_BODY2  = { r: 58,  g: 170, b: 135, a: 1.0 }
  COL_FOOD   = { r: 233, g: 69,  b: 96,  a: 1.0 }
  COL_FOOD_H = { r: 255, g: 120, b: 130, a: 1.0 }
  COL_SHADOW = { r: 0,   g: 0,   b: 0,   a: 0.35 }

  DIRS = {
    up:    [0, -1],
    down:  [0, 1],
    left:  [-1, 0],
    right: [1, 0]
  }.freeze

  OPP = { up: :down, down: :up, left: :right, right: :left }.freeze

  def initialize
    @snake = []
    @dir = :right
    @pending = :right
    @food = [0, 0]
    @score = 0
    @game_over = false
    @key_queue = []
    reset_game
    build_ui
    start_timer
  end

  def area_width
    PAD * 2 + GRID_W * CELL
  end

  def area_height
    HUD_H + PAD + GRID_H * CELL + PAD
  end

  def reset_game
    @snake = [[GRID_W / 2, GRID_H / 2]]
    @dir = :right
    @pending = :right
    @food = random_food
    @score = 0
    @game_over = false
    @key_queue.clear
    @area&.queue_redraw_all
  end

  def random_food
    loop do
      fx = rand(1...GRID_W - 1)
      fy = rand(1...GRID_H - 1)
      p = [fx, fy]
      return p unless @snake.include?(p)
    end
  end

  def grid_origin
    [PAD, HUD_H + PAD]
  end

  def process_key_queue
    k = @key_queue.shift
    return unless k
    @pending = k unless OPP[@dir] == k
  end

  def tick_move
    return if @game_over

    @dir = @pending
    dx, dy = DIRS[@dir]
    hx, hy = @snake.first
    nx = (hx + dx) % GRID_W
    ny = (hy + dy) % GRID_H
    new_head = [nx, ny]

    if @snake.include?(new_head)
      @game_over = true
      return
    end

    @snake.unshift(new_head)
    if new_head == @food
      @score += 1
      @food = random_food
    else
      @snake.pop
    end
  end

  def build_ui
    @main = window('Ruby Snake') {
      resizable false
      margined true

      vertical_box {
        padded true

        @area = area {
          on_draw do |params|
            draw_all(params)
          end

          on_key_down do |e|
            if @game_over
              case e[:key]
              when 'y', 'Y'
                reset_game
                true
              when 'n', 'N'
                LibUI.quit
                true
              else
                false
              end
            else
              dir = key_to_dir(e)
              if dir
                @key_queue << dir
                true
              else
                false
              end
            end
          end
        }
      }
    }

    @main.content_size(area_width + 32, area_height + 48)
  end

  def key_to_dir(e)
    case e[:key]
    when 'w', 'W' then :up
    when 's', 'S' then :down
    when 'a', 'A' then :left
    when 'd', 'D' then :right
    else
      ek = e[:ext_key]
      %i[up down left right].include?(ek) ? ek : nil
    end
  end

  def draw_all(params)
    aw = params[:area_width]
    ah = params[:area_height]

    rectangle(0, 0, aw, ah) { fill COL_BG }

    ox, oy = grid_origin

    # Subtle grid background panel
    rectangle(ox - 4, oy - 4, GRID_W * CELL + 8, GRID_H * CELL + 8) {
      fill r: 10, g: 20, b: 45, a: 1.0
      stroke r: 46, g: 196, b: 182, a: 0.35, thickness: 1.5
    }

    # Grid lines
    (0..GRID_W).each do |gx|
      figure(ox + gx * CELL, oy) {
        line(ox + gx * CELL, oy + GRID_H * CELL)
        stroke COL_GRID.merge(thickness: 1)
      }
    end
    (0..GRID_H).each do |gy|
      figure(ox, oy + gy * CELL) {
        line(ox + GRID_W * CELL, oy + gy * CELL)
        stroke COL_GRID.merge(thickness: 1)
      }
    end

    # Food (glow + core)
    fx, fy = @food
    cx = ox + fx * CELL + CELL / 2.0
    cy = oy + fy * CELL + CELL / 2.0
    circle(cx, cy, CELL * 0.42) { fill COL_SHADOW }
    circle(cx, cy - 1, CELL * 0.36) { fill COL_FOOD_H.merge(a: 0.45) }
    circle(cx, cy - 1, CELL * 0.28) { fill COL_FOOD }

    # Snake
    @snake.each_with_index do |(sx, sy), i|
      px = ox + sx * CELL
      py = oy + sy * CELL
      inset = i.zero? ? 3.5 : 4.5
      w = CELL - inset * 2
      h = CELL - inset * 2
      col = i.zero? ? COL_HEAD : (i.even? ? COL_BODY : COL_BODY2)
      rectangle(px + inset, py + inset + (i.zero? ? 0 : 0.5), w, h) {
        fill col
        stroke (i.zero? ? { r: 200, g: 255, b: 220, a: 0.9 } : { r: 30, g: 80, b: 60, a: 0.5 }).merge(thickness: i.zero? ? 2 : 1)
      }
    end

    # HUD
    text(ox, 6, aw - ox * 2) {
      string("Ruby Snake  ·  Score: #{@score}\nW A S D or arrow keys") {
        color r: 238, g: 244, b: 255, a: 1.0
        font family: 'Segoe UI', size: 14, weight: :bold
      }
    }

    return unless @game_over

    rectangle(0, 0, aw, ah) { fill r: 8, g: 12, b: 28, a: 0.72 }

    text(0, ah / 2 - 72, aw) {
      align :center
      string('GAME OVER') {
        color r: 255, g: 82, b: 82, a: 1.0
        font family: 'Segoe UI', size: 28, weight: :bold
      }
    }
    text(0, ah / 2 - 20, aw) {
      align :center
      string("Final score: #{@score}") {
        color r: 255, g: 214, b: 120, a: 1.0
        font family: 'Segoe UI', size: 18, weight: :medium
      }
    }
    text(0, ah / 2 + 28, aw) {
      align :center
      string('Y  Play again          N  Exit') {
        color r: 220, g: 230, b: 245, a: 1.0
        font family: 'Segoe UI', size: 14
      }
    }
  end

  def start_timer
    Glimmer::LibUI.timer(TICK) do
      unless @game_over
        process_key_queue
        tick_move
      end
      @area&.queue_redraw_all
    end
  end

  def launch
    @main.show
  end
end

unless defined?(Ocran)
  RubysnakeGui.new.launch
end
