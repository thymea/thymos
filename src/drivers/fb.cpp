#include <drivers/fb.hpp>

// Framebuffer request
__attribute__((used, section(".limine_requests")))
static volatile struct limine_framebuffer_request fbRequest = {
    .id = LIMINE_FRAMEBUFFER_REQUEST_ID,
    .revision = 0,
	.response = nullptr,
};

// Framebuffer pointer
volatile uint32_t *fbPtr {nullptr};

// Initialize framebuffer driver
Framebuffer::Framebuffer(void) : fb(fbRequest.response->framebuffers[0]) {
	// Ensure we have a framebuffer and fetch the first available one
	if(this->fb == nullptr || fbRequest.response->framebuffer_count < 1) utils::hlt();
	fbPtr = static_cast<volatile uint32_t *>(this->fb->address);
}
