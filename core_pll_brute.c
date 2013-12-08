
#include <stdio.h>

/* CLKDCOLDO = 2*(M/(N+1))*CLKINP */

#define CLKINP		24*1000*1000
#define CLKDCOLDO_DES	2*1000*1000*1000
#define CLKOUT_DES	192*1000*1000


#ifndef USE_FLOAT_VAR
# error need float...
#endif

int main( void )
{
#ifdef USE_INT_VAR

	int	CLKDCOLDO = 0;
	int	DIFF,diff = CLKDCOLDO_DES - CLKDCOLDO;
	int	M,m=999,N,n=999;
#elif (defined USE_LONG_VAR)
	long	CLKDCOLDO = 0;
	long	DIFF,diff = CLKDCOLDO_DES - CLKDCOLDO;
	long	M,m=999,N,n=999;
#elif ( defined USE_FLOAT_VAR)
	float	CLKDCOLDO = 0.0;
	float	DIFF,diff = (float)CLKDCOLDO_DES - CLKDCOLDO;
//	float	M,m=999.0,N,n=999.0;
	float	M,N;
#else
# error no var type defined
#endif
	printf("**********************************************************\n");
	printf("**  Core PLL                                            **\n");
	printf("**********************************************************\n");
	for ( M=2;M<2048;M++ )
	{
		for ( N=0;N<128;N++ )
		{
			CLKDCOLDO = 2*(M/(N+1))*CLKINP;
			DIFF = CLKDCOLDO_DES - CLKDCOLDO;
/*
			if ( DIFF < 0 ) DIFF = CLKDCOLDO - CLKDCOLDO_DES;
			if ( DIFF < diff)
			{
				diff = DIFF;
				m = M;
				n = N;
			}
*/
			if ( (DIFF==+0.0) || (DIFF==-0.0) )
			{
				printf("m: %4.0f, n: %2.0f\n",M,N);
//				printf("m: %4.0f, n: %2.0f, diff: %2.0f, CLKDCOLDO: %E\n",M,N,DIFF,CLKDCOLDO);
			}

		}
	}

#ifdef USE_INT_VAR
	printf("m: %i, n: %i, diff: %i\n",m,n,diff); 
#elif (defined USE_LONG_VAR)
	printf("m: %ld, n: %ld, diff: %ld\n",m,n,diff);
#elif ( defined USE_FLOAT_VAR)
//	printf("m: %f, n: %f, diff: %f\n",m,n,diff);
#else
# error no var type defined
#endif

	printf("\n\n\n\n");
#ifdef USE_FLOAT_VAR
	/* Per PLL */
	printf("**********************************************************\n");
	printf("**  Per PLL (assuming M2 val 5)                         **\n");
	printf("**********************************************************\n");
/*
	{
		float	CLKOUT;
		float	M2,m2=999;

		diff = CLKOUT_DES;
		for ( M=2;M<2048;M++ )
		{
			for ( N=0;N<128;N++ )
			{
				for ( M2=2;M2<256;M2++ )
				{
					CLKOUT = (M/(N+1))*CLKINP*(1/M2);
					DIFF = CLKOUT_DES - CLKOUT;
					if ( DIFF < 0 ) DIFF = CLKOUT - CLKOUT_DES;
					if ( DIFF < diff)
					{
						diff = DIFF;
						m = M;
						n = N;
						m2 = M2;
					}
				}
			}
		}
		printf("m: %f, n: %f, m2: %f, diff: %f\n",m,n,m2,diff);
	}
*/
	{
		float	CLKOUT;

		diff = CLKOUT_DES*5;
		for ( M=2;M<2048;M++ )
		{
			for ( N=0;N<128;N++ )
			{
				CLKOUT = (M/(N+1))*CLKINP;
				DIFF = CLKOUT_DES*5 - CLKOUT;
/*
				if ( DIFF < 0 ) DIFF = CLKOUT - CLKOUT_DES*5;
				if ( DIFF < diff)
				{
					diff = DIFF;
					m = M;
					n = N;
				}
*/
				if ( (DIFF==+0.0) || (DIFF==-0.0) )
				{
					printf("m: %4.0f, n: %2.0f\n",M,N);
//					printf("m: %4.0f, n: %2.0f, m2: 5.0, diff: %2.0f, CLKOUT: %E\n",M,N,DIFF,CLKOUT);
				}
			}
		}
//		printf("m: %f, n: %f, m2: 5, diff: %f\n",m,n,diff);
	}
#endif

	return 0;
}

