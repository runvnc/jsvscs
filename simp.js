var func1 = function(data) {
  var number, sum, i, len;

  sum = 0;
  for (i = 0, len = data.length; i < len; i++) {
    number = data[i];
    sum += number;
  }
  return sum;
};
