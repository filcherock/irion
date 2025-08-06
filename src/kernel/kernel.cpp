#include <stdint.h>
#include <stdbool.h>

volatile char* vga_buffer = (volatile char*)0xB8000;
static uint16_t vga_position = 0;

#define VGA_COLOR 0x07

#define VGA_DARK 0x0
#define VGA_BLUE 0x1
#define VGA_GREEN 0x2
#define VGA_CYAN 0x3
#define VGA_RED 0x4
#define VGA_PURPLE 0x5
#define VGA_YELLOW 0x6
#define VGA_GREY 0x8

#define KEYBOARD_DATA_PORT 0x60
#define KEYBOARD_STATUS_PORT 0x64

static char input_buffer[256]; 
static uint8_t buffer_index = 0;
static bool shift_pressed = false;

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    asm volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}


static inline void outb(uint16_t port, uint8_t value) {
    __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

unsigned char keymap[128] =
{
    0,  27, '1', '2', '3', '4', '5', '6', '7', '8',	/* 9 */
  '9', '0', '-', '=', '\b',	/* Backspace */
  '\t',			/* Tab */
  'q', 'w', 'e', 'r',	/* 19 */
  't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',	/* Enter key */
    0,			/* 29   - Control */
  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';',	/* 39 */
 '\'', '`',   0,		/* Left shift */
 '\\', 'z', 'x', 'c', 'v', 'b', 'n',			/* 49 */
  'm', ',', '.', '/',   0,				/* Right shift */
  '*',
    0,	/* Alt */
  ' ',	/* Space bar */
    0,	/* Caps lock */
    0,	/* 59 - F1 key ... > */
    0,   0,   0,   0,   0,   0,   0,   0,
    0,	/* < ... F10 */
    0,	/* 69 - Num lock*/
    0,	/* Scroll Lock */
    0,	/* Home key */
    19,	/* Up Arrow */
    0,	/* Page Up */
  '-',
    18,	/* Left Arrow */
    0,
    17,	/* Right Arrow */
  '+',
    0,	/* 79 - End key*/
    20,	/* Down Arrow */
    0,	/* Page Down */
    0,	/* Insert Key */
    0,	/* Delete Key */
    0,   0,   0,
    0,	/* F11 Key */
    0,	/* F12 Key */
    0,	/* All other keys are undefined */
};

unsigned char keymap_up[128] =
{
    0,  27, '!', '@', '#', '$', '%', '^', '&', '*',	/* 9 */
  '(', ')', '_', '+', '\b',	/* Backspace */
  '\t',			/* Tab */
  'q', 'w', 'e', 'r',	/* 19 */
  't', 'y', 'u', 'i', 'o', 'p', '{', '}', '\n',	/* Enter key */
    0,			/* 29   - Control */
  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ':',	/* 39 */
 '\"', '~',   0,		/* Left shift */
 '|', 'z', 'x', 'c', 'v', 'b', 'n',			/* 49 */
  'm', '<', '>', '?',   0,				/* Right shift */
  '*',
    0,	/* Alt */
  ' ',	/* Space bar */
    0,	/* Caps lock */
    0,	/* 59 - F1 key ... > */
    0,   0,   0,   0,   0,   0,   0,   0,
    0,	/* < ... F10 */
    0,	/* 69 - Num lock*/
    0,	/* Scroll Lock */
    0,	/* Home key */
    19,	/* Up Arrow */
    0,	/* Page Up */
  '-',
    18,	/* Left Arrow */
    0,
    17,	/* Right Arrow */
  '+',
    0,	/* 79 - End key*/
    20,	/* Down Arrow */
    0,	/* Page Down */
    0,	/* Insert Key */
    0,	/* Delete Key */
    0,   0,   0,
    0,	/* F11 Key */
    0,	/* F12 Key */
    0,	/* All other keys are undefined */
};

void set_cursor_position(uint16_t position) {
    uint16_t cursor_location = position;
    outb(0x3D4, 14); 
    outb(0x3D5, cursor_location >> 8);
    outb(0x3D4, 15); 
    outb(0x3D5, cursor_location & 0xFF);
}

void update_cursor() {
    set_cursor_position(vga_position);
}

bool keyboard_key(uint8_t keycode) {
    uint8_t status = inb(KEYBOARD_STATUS_PORT);
    if (status & 0x01) { 
        uint8_t scan_code = inb(KEYBOARD_DATA_PORT);

        // Обработка нажатий клавиш Shift
        if (scan_code == 0x2A || scan_code == 0x36) {
            shift_pressed = true;
        } else if (scan_code == 0xAA || scan_code == 0xB6) {
            shift_pressed = false;
        }

        if (scan_code == keycode) {
            return true;
        }
    }
    return false;
}
void put_char(char c, int colornum) {
    if (c == '\n') {
        vga_position += 80 - (vga_position % 80);
    } else {
        vga_buffer[vga_position * 2] = c;
        vga_buffer[vga_position * 2 + 1] = colornum;
        vga_position++;
    }
}

void print(const char* str, int colornum) {
    while (*str) {
        put_char(*str++, colornum);
    }
}

bool cstrcmp(const char* str1, const char* str2) {
    while (*str1 && *str2) {
        if (*str1 != *str2) {
            return false;
        }
        str1++;
        str2++;
    }
    return true;
}

void inputExpect(const char* str) {
    // there will be a code here
}

char* keyboard_input(void) {
    while (1) {
        uint8_t status = inb(KEYBOARD_STATUS_PORT);
        if (status & 0x01) { // Если есть данные
            uint8_t scan_code = inb(KEYBOARD_DATA_PORT);

            // Если клавиша отпущена, пропускаем
            if (scan_code & 0x80) continue;

            char c = shift_pressed ? keymap_up[scan_code] : keymap[scan_code];

            if (c == '\n') {
                // inputExpect(input_buffer);
                input_buffer[buffer_index] = 0; 
                buffer_index = 0; 
                print("\n", VGA_COLOR);
                print("IRION > ", VGA_COLOR);
                update_cursor();
                continue; 
            }

            if (buffer_index < sizeof(input_buffer) - 1) {
                input_buffer[buffer_index++] = c;
                put_char(c, VGA_COLOR); 
                update_cursor(); 
            }
        }
    }
}


extern "C" void kernel_main(uint32_t memory_map_address) {
    print("Welcome to Irion OS\n", VGA_GREEN);
    print("Press 'help' to get help-list\n", VGA_COLOR);
    print("IRION > ", VGA_COLOR);

    update_cursor();

    while (1) {
        keyboard_input();
    }
}
