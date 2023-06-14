interface OnBtnClickEventListener {
  void onClickEvent();
}

class Button {
  int x, y;
  int w, h;
  String text;
  boolean is_visible;
  private OnBtnClickEventListener event_listener;

  Button(int x, int y, int w, int h, String text, OnBtnClickEventListener event_listener) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.text = text;
    this.event_listener = event_listener;
    this.is_visible = true;
  }

  public void render() {
    if (this.is_visible) {
      stroke(0);
      strokeWeight(1);

      fill(244, 80, 80);
      rect(this.x, this.y, this.w, this.h, 12);

      fill(240, 240, 240);
      textSize(this.h/1.5f);
      textAlign(LEFT);
      float x_pos = this.x + ((this.w - textWidth(this.text)) / 2 );
      float y_pos = this.y + (this.h - (this.h/1.5f)/2);
      text(this.text, x_pos, y_pos);
    }
  }

  public void checkAndCall() {
    if (!this.is_visible) {
      return;
    }

    if (mouseX >= this.x &&
      mouseX <= this.x + this.w &&
      mouseY >= this.y &&
      mouseY <= this.y + this.h) {
      fill(249, 217, 73);
      rect(this.x, this.y, this.w, this.h, 12);
      this.event_listener.onClickEvent();
    }
  }
}
