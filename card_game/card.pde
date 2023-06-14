class Card {
  PImage img;
  private String name, type, rank;
  int value;
  int x, y;
  int id;

  Card(PImage img, String name, int value, String type, String rank, int id) {
    this.name = name;
    this.value = value;
    this.type = type;
    this.rank = rank;
    this.img  = img;
    this.id = id;
  }

  public String get_name() {
    return this.name;
  }
  public String get_type() {
    return this.type;
  }

  public String get_rank() {
    return this.rank;
  }

  public void render(int x, int y, boolean flipped) {
    this.x = x;
    this.y = y;

    if (flipped) {
      image(cardBack, x, y, IMG_W, IMG_H);
    } else {
      image(this.img, x, y, IMG_W, IMG_H);
    }
  }

  public void indicate_click() {
    fill(249, 217, 73);
    rect(this.x - 3, this.y - 3, IMG_W + 6, IMG_H + 6, 13);
    this.render(this.x, this.y, false);
  }

  public boolean check_clicked() {
    if (mouseX >= this.x &&
      mouseX <= this.x + IMG_W &&
      mouseY >= this.y &&
      mouseY <= this.y + IMG_H) {
      return true;
    }
    return false;
  }
}
