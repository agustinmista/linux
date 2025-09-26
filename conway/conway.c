#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <time.h>
#include <signal.h>

#define DEAD_COLOR "\033[0m"
#define ALIVE_CHAR "O"

struct termios orig_termios;
int rows, cols;
int **grid, **new_grid;

// Restore terminal
void reset_terminal() {
    tcsetattr(STDIN_FILENO, TCSANOW, &orig_termios);
    printf(DEAD_COLOR "\033[?25h"); // show cursor
    printf("\033[H\033[J");         // clear screen
}

// Ctrl-C handler
void sigint_handler(int sig) {
    (void)sig;
    reset_terminal();
    for(int i = 0; i < rows; i++) {
        free(grid[i]);
        free(new_grid[i]);
    }
    free(grid);
    free(new_grid);
    exit(0);
}

// Terminal setup
void init_terminal() {
    struct termios new_termios;
    tcgetattr(STDIN_FILENO, &orig_termios);
    atexit(reset_terminal);
    signal(SIGINT, sigint_handler);

    new_termios = orig_termios;
    new_termios.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &new_termios);
    printf("\033[?25l"); // hide cursor
}

// Get terminal size
void get_terminal_size(int *rows, int *cols) {
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    *rows = w.ws_row;
    *cols = w.ws_col;

    if (!*rows || !*cols) {
        *rows = 25;
        *cols = 80;
    }

}

// Count live neighbors
int count_neighbors(int **grid, int x, int y, int rows, int cols) {
    int count = 0;
    for(int i=-1;i<=1;i++)
        for(int j=-1;j<=1;j++)
            if(i!=0 || j!=0) {
                int nx=x+i, ny=y+j;
                if(nx>=0 && nx<rows && ny>=0 && ny<cols)
                    count += grid[nx][ny];
            }
    return count;
}

// Map number of neighbors to ANSI color
const char* color_for_neighbors(int n) {
    switch(n) {
        case 0: return "\033[0m";       // dead or isolated
        case 1: return "\033[1;30m";    // gray
        case 2: return "\033[1;34m";    // blue
        case 3: return "\033[1;32m";    // green
        case 4: return "\033[1;33m";    // yellow
        case 5: return "\033[1;31m";    // red
        case 6: return "\033[1;35m";    // magenta
        case 7: return "\033[1;36m";    // cyan
        case 8: return "\033[1;37m";    // white
        default: return "\033[0m";
    }
}

int main() {
    init_terminal();
    get_terminal_size(&rows, &cols);

    // Allocate grids
    grid = malloc(rows * sizeof(int*));
    new_grid = malloc(rows * sizeof(int*));
    for(int i=0;i<rows;i++){
        grid[i] = malloc(cols*sizeof(int));
        new_grid[i] = malloc(cols*sizeof(int));
    }

    // Initialize randomly
    srand(time(NULL));
    for(int i=0;i<rows;i++)
        for(int j=0;j<cols;j++)
            grid[i][j] = rand()%2;

    while(1){
        printf("\033[H"); // move cursor to top-left
        for(int i=0;i<rows;i++){
            for(int j=0;j<cols;j++){
                int neighbors = count_neighbors(grid,i,j,rows,cols);
                if(grid[i][j])
                    printf("%s" ALIVE_CHAR, color_for_neighbors(neighbors));
                else
                    printf(DEAD_COLOR " ");
            }
            printf("\n");
        }
        fflush(stdout);

        // Next generation
        for(int i=0;i<rows;i++){
            for(int j=0;j<cols;j++){
                int neighbors = count_neighbors(grid,i,j,rows,cols);
                if(grid[i][j])
                    new_grid[i][j] = (neighbors==2 || neighbors==3)?1:0;
                else
                    new_grid[i][j] = (neighbors==3)?1:0;
            }
        }

        // Swap grids
        int **tmp = grid;
        grid = new_grid;
        new_grid = tmp;

        usleep(1000000); // 1 second
    }

    return 0;
}

