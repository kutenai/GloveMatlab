function u_prime = noise_f(x,u);
u_prime(1) = -25*u(2)-2*0.2*5*u(1)+12;
u_prime(2) = u(1);
