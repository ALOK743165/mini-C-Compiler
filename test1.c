//without error
int main()
{
	int t, a = 0, b = 0;
	scanf("%d", &t);

	while(t--){
		float arr[5][5];
		int i = 0;
		for(i = 0;i < 5; i++){
			if(arr[0][i] % 2 == 0){
				a += 1;
			}
			else{
				b += 1;	
			}
		}
	}
	printf("a = %d\nb = %d", a, b);
	return;
}
