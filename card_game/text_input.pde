interface InputEventListener {
  void onInputChanged(String input);
}


class TextInput {
  InputEventListener ev;
  boolean is_focused;
  int x, y;
  String display_text;
  private String input;
  private int last_blink_frame;
  private int frame_count;
  
  TextInput(int x, int y, String display_text, InputEventListener event_listener) {
    this.ev = event_listener;
    this.x = x;
    this.y = y;
    this.display_text = display_text;
    this.input = "";
    this.is_focused = false;
    this.last_blink_frame = 0;
  }
  
  void render() {
    textAlign(LEFT, TOP);
    text(this.display_text + this.input, this.x, this.y);
    
    stroke(240, 240, 240);
    strokeCap(SQUARE);
    strokeWeight(3);
    noFill();
      
    float text_h = textAscent() + textDescent();
    float x_pos = textWidth(this.display_text + this.input) + this.x;
    line(this.x, this.y + text_h, this.x + textWidth(this.display_text + this.input), this.y + text_h);
    
    if (!this.is_focused) {
      return;      
    }

    if (last_blink_frame + FRAMERATE - (int) FRAMERATE / 1.5 <= this.frame_count) {
      line(x_pos, this.y, x_pos, this.y + text_h);
      if (last_blink_frame + FRAMERATE == this.frame_count)
        this.last_blink_frame = this.frame_count;
    }
    
    this.frame_count++;
  }
  
  void setFocus(boolean is_focused) {
    this.is_focused = is_focused;
  }
  
  void checkFocus() {

    float tw = textWidth(this.display_text + this.input);
    float th = textAscent() + textDescent(); 
    if (mouseX >= this.x - 10 &&
      mouseX <= this.x + tw + 20 &&
      mouseY >= this.y &&
      mouseY <= this.y + th) {
      fill(249, 217, 73);
      rect(this.x - 10, this.y, tw + 20, th);
      this.is_focused = true;
      this.last_blink_frame = this.frame_count;
      
    } else {
      this.is_focused = false;
    }
  }
  
  void checkInput() {
    if (!this.is_focused) {
      return;
    }
    if (int(key) == 8) {
      if (input.length() > 0) {
        input = input.substring(0, input.length() - 1);
        this.ev.onInputChanged(input);
      }
    } else if (int(key) == 10) {
     // Maybe do something here sometime
    } else {
      input += key;
      this.ev.onInputChanged(input);
    }
  }
}
