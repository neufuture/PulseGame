

class Zone {

  public:
  
  int start, end, strandId, id;
  bool active;
  long startTime, duration;


  Zone(){
  }
  
  void setZone(int _start, int _strandId, int _id) {
    start    = _start;
    end      = start + 10;
    strandId = _strandId;
    id       = _id;
  }


};

