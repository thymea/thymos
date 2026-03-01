#include <drivers/fb.hpp>

// Framebuffer request
__attribute__((used, section(".limine_requests")))
static volatile struct limine_framebuffer_request fbRequest = {
    .id = LIMINE_FRAMEBUFFER_REQUEST_ID,
    .revision = 0,
	.response = nullptr,
};

// Initialize framebuffer driver
Framebuffer::Framebuffer(void) {
	// Ensure we have a framebuffer and fetch the first available one
	if(fbRequest.response == nullptr || fbRequest.response->framebuffer_count < 1) utils::hlt();
	this->fb = fbRequest.response->framebuffers[0];
}

void Framebuffer::drawLine(void) {
	for (std::size_t i = 0; i < 100; i++) {
        volatile uint32_t *fb_ptr = (volatile uint32_t *)this->fb->address;
        fb_ptr[i * (this->fb->pitch / 4) + i] = 0xffffff;
    }
}
