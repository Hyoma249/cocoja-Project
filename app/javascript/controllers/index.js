import { application } from "./application";

import HelloController from "./hello_controller";
application.register("hello", HelloController);

import PasswordVisibilityController from "./password_visibility_controller";
application.register("password-visibility", PasswordVisibilityController);

import PostPrevController from "./post_prev_controller";
application.register("post-prev", PostPrevController);

import ImageInputController from "./image_input_controller";
application.register("image-input", ImageInputController);

import FlashController from "./flash_controller";
application.register("flash", FlashController);

import VoteController from "./vote_controller";
application.register("vote", VoteController);

import InfiniteScrollController from "./infinite_scroll_controller";
application.register("infinite-scroll", InfiniteScrollController);

import AutocompleteController from "./autocomplete_controller";
application.register("autocomplete", AutocompleteController);

import PostScrollController from "./post_scroll_controller";
application.register("post-scroll", PostScrollController);

import SwiperController from "./swiper_controller";
application.register("swiper", SwiperController);
