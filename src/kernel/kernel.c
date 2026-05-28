void _start(){
	__asm__ volatile(
				"l_0:\n"
				"cli\n"
				"jmp l_0\n"
			); 
}
