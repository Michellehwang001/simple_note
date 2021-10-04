
void main() {
  var colorArr = ['orange', 'yellow'];
  try {
    colorArr[1] = 'aaa';
  } catch (e) {
    print(e);
  } finally {
    print('This is always written..');
  }
  print (colorArr.length);
}


