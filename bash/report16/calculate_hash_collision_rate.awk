#!/usr/bin/gawk -f

function factorial(n) {
  return n <= 1 ? 1: n * factorial(n - 1);
}

function Poisson(lambda, n) {
  return exp(-lambda) * (lambda ^ n) / factorial(n);
}

function hash_collision_rate(lambda) {
  p0 = Poisson(lambda, 0);
  p1 = Poisson(lambda, 1);
  return (1 - p0 - p1) / (1 - p0)
}

{
  print $1, hash_collision_rate($1);
}
