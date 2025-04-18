// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application";

// 明示的にコントローラーを登録
import HelloController from "./hello_controller";
application.register("hello", HelloController);

import SliderController from "./slider_controller";
application.register("slider", SliderController);

import PasswordVisibilityController from "./password_visibility_controller";
application.register("password-visibility", PasswordVisibilityController);

import PostPrevController from "./post_prev_controller";
application.register("post-prev", PostPrevController);

import ImageInputController from "./image_input_controller";
application.register("image-input", ImageInputController);

import FlashController from "./flash_controller";
application.register("flash", FlashController);
