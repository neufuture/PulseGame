
class Pulse {

  public:
  int speed;
  int strandId;
  int loc;
  int direction;
  long lastTime;
  bool active;

  Pulse() {
  }

  void setPulse(int _strandId, int _direction, int _speed) {
    strandId = _strandId;
    if (_direction==0) direction = 1;
    else direction  = -1;
    speed = _speed;
    if (direction == 1) loc = 2;
    else loc = 48;
    active = true;
  }


};


