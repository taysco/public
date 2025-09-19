#ifndef _H_PROTO

#ifdef STDC_HEADERS
#define PROTO(x) x
#define PROTO1(a,b) (a b)
#define PROTO2(a1,b1,a2,b2) (a1 b1, a2 b2) 
#define PROTO3(a1,b1,a2,b2,a3,b3) (a1 b1, a2 b2, a3 b3)
#define PROTO4(a1,b1,a2,b2,a3,b3,a4,b4) \
              (a1 b1, a2 b2, a3 b3, a4 b4)
#define PROTO5(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5) \
              (a1 b1, a2 b2, a3 b3, a4 b4, a5 b5)
#define PROTO6(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,a6,b6) \
              (a1 b1, a2 b2, a3 b3, a4 b4, a5 b5, a6 b6)
#else
#define PROTO(x) ()
#define PROTO1(a,b) (b) a b;
#define PROTO2(a1,b1,a2,b2) (b1, b2) a1 b1; a2 b2; 
#define PROTO3(a1,b1,a2,b2,a3,b3) (b1, b2, b3) a1 b1; a2 b2; a3 b3;
#define PROTO4(a1,b1,a2,b2,a3,b3,a4,b4) (b1, b2, b3, b4) \
              a1 b1; a2 b2; a3 b3; a4 b4;
#define PROTO5(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5) \
              (b1, b2, b3, b4, b5) \
              a1 b1; a2 b2; a3 b3; a4 b4; a5 b5;
#define PROTO6(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,a6,b6) \
              (b1, b2, b3, b4, b5, b6) \
              a1 b1; a2 b2; a3 b3; a4 b4; a5 b5; a6 b6;
#endif
#endif /* !_H_PROTO */
