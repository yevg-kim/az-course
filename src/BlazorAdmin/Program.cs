﻿using System;
using System.Net.Http;
using System.Threading.Tasks;
using BlazorAdmin;
using BlazorAdmin.Services;
using Blazored.LocalStorage;
using BlazorShared;
using BlazorShared.Models;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

var builder = WebAssemblyHostBuilder.CreateDefault(args);

builder.RootComponents.Add<App>("#admin");
builder.RootComponents.Add<HeadOutlet>("head::after");

var configSection = builder.Configuration.GetRequiredSection(BaseUrlConfiguration.CONFIG_NAME);
builder.Services.Configure<BaseUrlConfiguration>(configSection);

builder.Services.AddScoped(sp => new HttpClient() { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });

builder.Services.AddScoped<ToastService>();
builder.Services.AddScoped<HttpService>();

builder.Services.AddBlazoredLocalStorage();

builder.Services.AddAuthorizationCore();
builder.Services.AddScoped<AuthenticationStateProvider, CustomAuthStateProvider>();
builder.Services.AddScoped(sp => (CustomAuthStateProvider)sp.GetRequiredService<AuthenticationStateProvider>());

builder.Services.AddBlazorServices();

builder.Logging.AddConfiguration(builder.Configuration.GetRequiredSection("Logging"));

await WorkWithLocalStorage(builder);

await builder.Build().RunAsync();

static async Task WorkWithLocalStorage(WebAssemblyHostBuilder builder)
{
    var sp = builder.Services.BuildServiceProvider();
    var localStorageService = sp.GetRequiredService<ILocalStorageService>();

    await UpdateSettingsFromLocalStorage(localStorageService, builder.Services);
    await ClearLocalStorageCache(localStorageService);
}

static async Task UpdateSettingsFromLocalStorage(ILocalStorageService localStorageService, IServiceCollection services)
{
    var settings = await localStorageService.GetItemAsync<BaseUrlConfiguration>("settings");
    services.PostConfigure<BaseUrlConfiguration>(config => config.ApiBase = settings.ApiBase);
}

static async Task ClearLocalStorageCache(ILocalStorageService localStorageService)
{
    await localStorageService.RemoveItemAsync(typeof(CatalogBrand).Name);
    await localStorageService.RemoveItemAsync(typeof(CatalogType).Name);
    await localStorageService.RemoveItemAsync("settings");
}
