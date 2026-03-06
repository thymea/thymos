// Freestanding headers
#include <stddef.h>

// Limine
#include <limine/limine.h>

// OS
#include <utils.hpp>
#include <drivers/framebuffer.hpp>

// Architecture specifics
#include <arch/common.hpp>
#ifdef ARCH_x86_64
	static CPU::Idt idt;
#endif

#define BG_COLOR 0x000000
#define FG_COLOR 0x00aa00
#define TAB_SPACES 4

// Limine base revision
__attribute__((used, section(".limine_requests")))
static volatile uint64_t limineBaseRev[] = LIMINE_BASE_REVISION(5);

// Limine requests start and end marker
__attribute__((used, section(".limine_requests_start")))
static volatile uint64_t limineReqStartMarker[] = LIMINE_REQUESTS_START_MARKER;
__attribute__((used, section(".limine_requests_end")))
static volatile uint64_t limineReqEndMarker[] = LIMINE_REQUESTS_END_MARKER;

// Limine Requests
__attribute__((used, section(".limine_requests")))
static volatile struct limine_firmware_type_request firmwareTypeRequest = {
	.id = LIMINE_FIRMWARE_TYPE_REQUEST_ID,
	.revision = 0,
	.response = nullptr,
};

// Font
extern ssfn_font_t _binary____fonts___unifont_sfn_start;

// Framebuffer
static Drivers::Framebuffer fb {};
const static Font_t font {
	.font = &_binary____fonts___unifont_sfn_start,
	.width = 16,
	.height = 16,
};

// Kernel entry point
extern "C" void kmain(void) {
	// Ensure Limine base revision is supported
	if(LIMINE_BASE_REVISION_SUPPORTED(limineBaseRev) == false) CPU::Utils::hlt();

	// Initialize the framebuffer
	fb.init(font.font, BG_COLOR, FG_COLOR);
	printf("[FRAMEBUFFER] INITIALIZED\n");
	printf("[FRAMEBUFFER] WIDTH -> %lu\n", fb.getFramebuffer()->width);
	printf("[FRAMEBUFFER] HEIGHT -> %lu\n", fb.getFramebuffer()->height);
	printf("[FRAMEBUFFER] PITCH -> %lu\n", fb.getFramebuffer()->pitch);
	printf("[FRAMEBUFFER] COLOR DEPTH -> %hu\n", fb.getFramebuffer()->bpp);
	printf("\n");

	// Initialize CPU stuff
#ifdef ARCH_x86_64
	CPU::gdtInit();
	printf("[CPU] GDT INITIALIZED\n");
	idt.init();
	printf("[CPU] IDT INITIALIZED\n");
#endif
	printf("\n");

	// Display firmware type
	struct limine_firmware_type_response *firmwareType = firmwareTypeRequest.response;
	switch(firmwareType->firmware_type) {
		case 0:
			printf("[FIRMWARE] x86 BIOS\n");
			break;
		case 1:
			printf("[FIRMWARE] 32-BITS UEFI\n");
			break;
		case 2:
			printf("[FIRMWARE] 64-BITS UEFI\n");
			break;
		case 3:
			printf("[FIRMWARE] SBI\n");
			break;
	}

	asm("int $0");

	// Halt system
	CPU::Utils::hlt();
}

// Handle printing characters for `printf` and all
void putchar_(char c) {
	// Figure out if character position will be outside screen
	bool isYOffScreen {(ssfn_dst.y + font.height) > ssfn_dst.h};
	bool isXOffScreen {(ssfn_dst.x + font.width) > ssfn_dst.w};

	// Handle characters
	switch(c) {
		// Newline
		case '\n':
			ssfn_dst.x = 0;
			if(isYOffScreen) return;
			else ssfn_dst.y += font.height;
			break;

		/// Tabs
		case '\t':
			for(uint8_t i = 0; i < TAB_SPACES; i++) putchar_(' ');
			break;
		
		// Normal character
		default:
			if(isYOffScreen) fb.clear();
			else if(isXOffScreen) putchar_('\n');
			else ssfn_putc(c);
			break;
	}
}

// Interrupt handler
extern "C" [[noreturn]] void interruptHandler(void) {
	ssfn_dst.fg = 0xff0000;
	printf("\nSomething happened idk man\n");

	// Halt the system
	CPU::Utils::hlt();
}
